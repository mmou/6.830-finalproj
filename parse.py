import re, sys

class TestRecord(object):
	workload = ""
	variable_prop_value = ""
	overall_throughput = ""
	update_latency = ""
	read_latency = ""
	insert_latency = ""
	rmw_latency = ""
	cleanup_latency = ""

	overall_throughput_pattern = re.compile("\[OVERALL\]")
	update_latency_pattern = re.compile("\[UPDATE\]")
	rmw_latency_pattern = re.compile("\[READ-MODIFY-WRITE\]")
	read_latency_pattern = re.compile("\[READ\]")
	insert_latency_pattern = re.compile("\[INSERT\]")
	cleanup_latency_pattern = re.compile("\[CLEANUP\]")

	def __init__(self, workload, variable_prop_value):
		self.workload = workload
		self.variable_prop_value = variable_prop_value

	# input looks like "[READ-MODIFY-WRITE], AverageLatency(us), 40054.980842988414	"
	def parse_and_insert(self, str):
		line_tokens = str.strip().split(" ")
		if re.search(self.overall_throughput_pattern, line_tokens[0]):
			self.overall_throughput = line_tokens[-1]
		elif re.search(self.update_latency_pattern, line_tokens[0]):
			self.update_latency = line_tokens[-1]
		elif re.search(self.read_latency_pattern, line_tokens[0]):
			self.read_latency = line_tokens[-1]
		elif re.search(self.insert_latency_pattern, line_tokens[0]):
			self.insert_latency = line_tokens[-1]
		elif re.search(self.rmw_latency_pattern, line_tokens[0]):
			self.rmw_latency = line_tokens[-1]
		elif re.search(self.cleanup_latency_pattern, line_tokens[0]):
			self.cleanup_latency = line_tokens[-1]
		else:
			print "FAILURE!!!"				

	def to_string(self):
		return "{0}\t{1}\t{2}\t{3}\t{4}\t{5}\t{6}\t{7}".format(
			self.variable_prop_value, 
			self.workload, 
			self.overall_throughput,
			self.update_latency,
			self.read_latency,
			self.insert_latency,
			self.rmw_latency,
			self.cleanup_latency)


def parse_and_output(input_file_path, output_file_path):
	test_pattern = re.compile('.txt')
	data_pattern = re.compile('Throughput|AverageLatency')

	records = []

	with open(input_file_path) as f:
	    for line in f:
	    	if re.search(test_pattern, line):
	    		line_tokens = line.split("_")
	    		records.append(TestRecord(line_tokens[0][-1], line_tokens[1]))
	    	else:
		    	result = re.search(data_pattern, line)
		    	if result:
		    		records[-1].parse_and_insert(line)

	with open(output_file_path, "w") as f:
		f.write("\n".join([record.to_string() for record in records]))
               

if __name__ == "__main__":
	# expecting 2 arguments!
	parse_and_output(sys.argv[1], sys.argv[2])
