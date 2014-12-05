#!/bin/bash      

database=dynamodb
db_prop=dynamodb/conf/dynamodb.properties
workload=(a b c d) #put more
#for cassandra
#db_prop= hosts="192.168.122.89"

#client/thread

#parameters
threads=(1 10 15)
threads_opcount=10
threads_recordcount=10
threads_output=threads_output_all
rm -f $threads_output

for workload_num in ${workload[@]}; do
        echo $workload_num
        ./bin/ycsb load $database -P $db_prop -threads 10 -p recordcount=$threads_recordcount -P workloads/workload$workload_num -s > workload${workload_num}_load_res.txt

        for i in ${threads[@]}; do
                ./bin/ycsb run $database -P $db_prop -threads $i -p operationcount=$threads_opcount -P workloads/workload$workload_num -s > workload${workload_num}_${i}_run_res.txt
                printf "Threads \n workload${workload_num}_${i}_run_res.txt \n with parameter workload $workload_num -threads $i -p operationcount=$threads_opcount -P workloads/workload$workload_num \n created on $(date +%Y%m%d)" >> $threads_output
                grep [overall] workloada_${i}_run_res.txt | grep -v YCSB | grep -v com.yahoo >> $threads_output
        done
done