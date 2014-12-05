#!/bin/bash      

database=dynamodb
db_prop=dynamodb/conf/dynamodb.properties
workload=(a b c d) #put more
#for cassandra
#db_prop= hosts="192.168.122.89"

#throughput vs latency    

#parameters
throughput=(500 1000)
tl_threads=10
tl_opcount=10
tl_recordcount=10
tl_output=tl_output_all

rm -f $tl_output
./bin/ycsb load $database -P $db_prop -threads $tl_threads -p recordcount=$tl_recordcount -P workloads/workloada -s > workloada_load_res.txt

for i in ${throughput[@]}; do
        for workload_num in ${workload[@]}; do
                echo target $i 'workload'  $workload_num
                ./bin/ycsb run $database -P $db_prop -threads $tl_threads -p recordcount=$tl_recordcount -p operationcount=$tl_opcount -target $i -P workloads/workload$workload_num -s > workload${workload_num}_${i}_run_res.txt
                printf "workload${workload_num}_${i}_run_res.txt \n with parameter workload $workload_num -threads $tl_threads -p operationcount=$tl_opcount -P workloads/workload$workload_num \n created on $(date +%Y%m%d)\n" >> $tl_output
                grep [overall] workloada_${i}_run_res.txt | grep -v YCSB | grep -v com.yahoo >> $tl_output
        done
done