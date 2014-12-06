#!/bin/bash      

#for dynamodb
#database=dynamodb
#db_prop=dynamodb/conf/dynamodb.properties

#for cassandra
#database=cassandra-10
#db_prop="54.149.97.229"

#for mongodb
# database=mongodb
# db_prop=54.68.194.27:27017

#client/thread

#parameters
threads=(1 10 25 50 75 100 250 500 750 1000)
threads_opcount=100000
threads_recordcount=1000000
threads_output=threads_output_all
workload=(a b c f d) #put more

rm -f $threads_output

if [ $database == dynamodb ]; then
        echo loading $database
        ./bin/ycsb load $database -P $db_prop -threads 10 -p recordcount=$threads_recordcount -P workloads/workloada -s > workloada_load_res.txt
elif [ $database == cassandra-10 ]; then
        echo loading $database
        ./bin/ycsb load $database -p hosts=$db_prop -threads 10 -p recordcount=$threads_recordcount -P workloads/workloada -s > workloada_load_res.txt
elif [ $database == mongodb ]; then
        echo loading $database
        ./bin/ycsb load $database -p mongodb.url=mongodb://$db_prop -threads 10 -p recordcount=$threads_recordcount -P workloads/workloada -s > workloada_load_res.txt
fi

for i in ${threads[@]}; do
        for workload_num in ${workload[@]}; do
            echo target $i 'workload'  $workload_num
            if [ $database == dynamodb ]; then
                    echo running $database
                    ./bin/ycsb run $database -P $db_prop -threads $i -p recordcount=$threads_recordcount -p operationcount=$threads_opcount -P workloads/workload$workload_num -s > workload${workload_num}_${i}_run_res.txt
            elif [ $database == cassandra-10 ]; then
                    echo running $database
                    ./bin/ycsb run $database -p hosts=$db_prop -threads $i -p recordcount=$threads_recordcount -p operationcount=$threads_opcount -P workloads/workload$workload_num -s > workload${workload_num}_${i}_run_res.txt
            elif [ $database == mongodb ]; then
                    echo running $database
                    ./bin/ycsb run $database -p mongodb.url=mongodb://$db_prop -threads $i -p recordcount=$threads_recordcount -p operationcount=$threads_opcount -P workloads/workload$workload_num -s > workload${workload_num}_${i}_run_res.txt
            fi

            printf "Threads \n workload${workload_num}_${i}_run_res.txt \n with parameter workload $workload_num -threads $i -p operationcount=$threads_opcount -P workloads/workload$workload_num \n created on $(date +%Y%m%d)" >> $threads_output
            grep [overall] workloada_${i}_run_res.txt | grep -v YCSB | grep -v com.yahoo >> $threads_output
        done
done