#! /usr/bin/python
import commands,time
import fileinput, sys, cgitb
#cgitb.enable()
#print "Content-type: text/html\n\r\n\r"

def read_incomming(file_name='/proc/net/dev'):
	f = open(file_name)
	lines = f.read()
	lines = lines.split('\n');
	f.close()
	data = []
	for line in lines:
		#print line.find(':');
		if line.find(':')>0:
			line = line.split(':')[1]
#			print line
			data.append(line.split())
	
	#count sum of eache interface
	in_bytes=0
	in_pkt=0
	out_bytes=0
	out_pkt=0

	for line in data:
		in_bytes =in_bytes+ int(line[0])
		in_pkt = in_pkt + int(line[1])
		out_bytes =out_bytes+ int(line[8])
		out_pkt = out_pkt + int(line[9])
	output={}
	output={"in_byte":in_bytes,"in_packet":in_pkt,"out_byte":out_bytes,"out_packet":out_pkt}
	return output

def get_load():
	load = commands.getoutput('ps aux|grep monitor_ |grep -v grep|grep -v SCREEN')	
	if load.find('trafficmonitor')>0:
		return load.split()[2]	
	else:
		return ""
def get_date():
	text = commands.getoutput('date')
	return text.split()[3]	

def set_last_time(traffic_data,path="/tmp/traffic_lasttime"):
	traffic_data['time']=time.time()	
	this_time = "%(in_byte)d %(in_packet)d %(out_byte)d %(out_packet)d %(time)f"%traffic_data
	commands.getoutput('echo '+this_time+' > '+path);
	return 0

def get_last_time(path="/tmp/traffic_lasttime"):
	f = 0
	
	try:
		f=open(path)
		line = f.read()
		f.close()
	except Exception:
		print "error while reading tmp file :"
		return {'in_byte':0, 'in_packet':0, 'out_byte':0, 'out_packet':0, 'time':0}
	line = line.split();
	if len(line)<5:
		print "tmp file malformat"
		return {'in_byte':0, 'in_packet':0, 'out_byte':0, 'out_packet':0, 'time':0}
			
	output = {'in_byte':int(line[0]), 'in_packet':int(line[1]), 'out_byte':int(line[2]), 'out_packet':int(line[3]), 'time':float(line[4])}
	#print line
	return output

#read new data
incomming = read_incomming()
#get last data
last_time = get_last_time()
#set last time data
set_last_time(incomming)

#generate ouptut
time_def = time.time()-last_time['time'];
output_data={'byte_avg':(incomming['in_byte']-last_time['in_byte'])/time_def,'pkt_avg':(incomming['in_packet']-last_time['in_packet'])/time_def,'cpu':get_load(),'time':get_date(),'duration':time_def}
output_string = '%(byte_avg)f %(pkt_avg)f %(cpu)s %(time)s %(duration)s'%output_data
print output_string

