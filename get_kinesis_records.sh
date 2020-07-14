#!/usr/bin/env bash

if ! aws_bin="$(which aws)" 2>/dev/null; then
    echo "aws cli is missing; you can get it from https://aws.amazon.com/cli/"
    exit 1
fi

if ! jq_bin="$(which jq)" 2>/dev/null; then
    echo "jq is missing; you can get it from https://stedolan.github.io/jq/"
    exit 1
fi

# print partition-key for each record
: "${print_pk:=0}"

: "${debug_aws_commands:=0}"
aws() {
    if [[ "$debug_aws_commands" == 1 ]]; then
        echo "aws $*" 1>&2
    fi
    "$aws_bin" "$@"
}

jq() {
    "$jq_bin" "$@"
}

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

shutdown_now=0
ctrl_c() {
    shutdown_now=1
}

# set to LATEST for latest or a relative-time in the past using "date string"
# specifier as described under "DATE STRING" in `man date`
: "${time:=LATEST}"
if [[ "$time" == LATEST ]]; then
    time_spec=($time)
else
    time_spec=(AT_TIMESTAMP --timestamp "$(date +%s -d "$time").000")
fi

get_shards() {
    aws kinesis describe-stream --stream-name "$1" |
        jq -r '.StreamDescription.Shards[].ShardId'
}

get_shard_iterators() {
    for shard in $(get_shards "$1"); do
        aws kinesis get-shard-iterator --stream-name "$1" --shard-id "$shard" \
            --shard-iterator-type "${time_spec[@]}" |
                jq -r '.ShardIterator'
    done
}

iterate() {
    iterator="$1"
    while [[ "$shutdown_now" == 0 ]] && [ -n "$iterator" ]; do
        if ! op="$(aws kinesis get-records --shard-iterator "$iterator")"; then
            sleep 1
            continue
        fi

        jq -r '.Records[]|(.PartitionKey + "\t" + .Data)' <<<"$op" |
            while IFS=$'\t' read -ra rec; do
				if [[ "$print_pk" == 1 ]]; then
					echo -e "\\nPK: ${rec[0]}"
				else
					echo
				fi
                base64 -d <<<"${rec[1]}"
            done

        iterator="$(jq -r '.NextShardIterator' <<<"$op")"
        msBehind="$(jq -r '.MillisBehindLatest' <<<"$op")"
        if [[ "$msBehind" == 0 ]]; then
            sleep 2
        else
            sleep .5
        fi
    done
}

if [ -z "$1" ] || [[ "$1" == help ]]; then
    cat <<HELP
Usage: $(basename "$0") <StreamName>
Under the hood, this tool uses aws-cli. This means that all environment variables
and shared-credentials setup will work with this too.
You can specify the relative time from NOW, to start the iterator.
Example:
    # Iterate and get records from the Kinesis stream "PlayerData"
    # under "profile-name-1" profile, starting from 10mins ago
    AWS_PROFILE=profile-name-1 time="10 mins ago" ./$(basename "$0") PlayerData
HELP
    exit 0
fi

for itr in $(get_shard_iterators "$1"); do
    iterate "$itr" &
done

wait
