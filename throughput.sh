#!/bin/bash      

#database=dynamodb
#db_prop=dynamodb/conf/dynamodb.properties
workload=(a b c d) #put more
#for cassandra
#database=cassandra-10
#db_prop= 192.168.122.89

#for mongodb
database=mongodb
db_prop=54.68.194.27:27017

#throughput vs latency    

#parameters
throughput=(500 1000)
tl_threads=10
tl_opcount=10
tl_recordcount=10
tl_output=tl_output_all

rm -f $tl_output

if [ $database == dynamodb ]; then
        echo loading dynamodb
        ./bin/ycsb load $database -P $db_prop -threads $tl_threads -p recordcount=$tl_recordcount -P workloads/workloada -s > workloada_load_res.txt
elif [ $database == cassandra-10 ]; then
        echo loading cassandra-10
        ./bin/ycsb load $database -P hosts=$db_prop -threads $tl_threads -p recordcount=$tl_recordcount -P workloads/workloada -s > workloada_load_res.txt
elif [ $database == mongodb ]; then
        echo loading mongodb
        ./bin/ycsb load $database -p mongodb.url=mongodb://$db_prop -threads $tl_threads -p recordcount=$tl_recordcount -P workloads/workloada -s > workloada_load_res.txt
fi

for i in ${throughput[@]}; do
        for workload_num in ${workload[@]}; do
                echo target $i 'workload'  $workload_num
                if [ $database == dynamodb ]; then
                        echo running dynamodb
                        ./bin/ycsb run $database -P $db_prop -threads $tl_threads -p recordcount=$tl_recordcount -p operationcount=$tl_opcount -target $i -P workloads/workload$workload_num -s > workload${workload_num}_${i}_run_res.txt
                elif [ $database == cassandra-10 ]; then
                        echo running cassandra-10
                        ./bin/ycsb run $database -P hosts=$db_prop -threads $tl_threads -p recordcount=$tl_recordcount -p operationcount=$tl_opcount -target $i -P workloads/workload$workload_num -s > workload${workload_num}_${i}_run_res.txt
                elif [ $database == mongodb ]; then
                        echo running mongodb
                        ./bin/ycsb run $database -p mongodb.url=mongodb://$db_prop -threads $tl_threads -p recordcount=$tl_recordcount -p operationcount=$tl_opcount -target $i -P workloads/workload$workload_num -s > workload${workload_num}_${i}_run_res.txt
                fi

                printf "workload${workload_num}_${i}_run_res.txt \n with parameter workload $workload_num -threads $tl_threads -p operationcount=$tl_opcount -P workloads/workload$workload_num \n created on $(date +%Y%m%d)\n" >> $tl_output
                grep [overall] workloada_${i}_run_res.txt | grep -v YCSB | grep -v com.yahoo >> $tl_output
        done
done
