import json
import base64
import gzip
import io
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def safe_convert_int(value, default=0):
   """Helper function to safely convert values to integers"""
   try:
       return int(value) if value and value != "-" else default
   except ValueError:
       return default

def safe_convert_float(value, default=0.0):
   """Helper function to safely convert values to floats"""
   try:
       return float(value) if value and value != "-" else default
   except ValueError:
       return default

def process_field(value):
   """Helper function to process field values, converting '-' to None"""
   return None if value == "-" else value

def handler(event, context):
   output = []
  
   for record in event['records']:
       try:
           # Decode base64-encoded data
           payload = base64.b64decode(record['data'])
          
           try:
               # Try direct string parsing first (more efficient)
               log_line = payload.decode('utf-8').strip()
           except UnicodeDecodeError:
               # Fallback to gzip if needed
               with io.BytesIO(payload) as compressed_stream:
                   with gzip.GzipFile(fileobj=compressed_stream, mode='rb') as gz:
                       log_line = gz.read().decode('utf-8').strip()
          
           # Skip header lines
           if log_line.startswith('#'):
               continue
              
           # Split into fields
           fields = log_line.split('\t')
          
           # Create transformed log with all fields
           transformed_log = {
               # Standard CloudFront Fields
               "@timestamp": fields[0],
               "client_ip": process_field(fields[1]),
               "status_code": safe_convert_int(fields[2]),
               "http_method": process_field(fields[3]),
               "uri_stem": process_field(fields[4]),
               "edge_location": process_field(fields[5]),
               "user_agent": process_field(fields[6]),
               "referer": process_field(fields[7]),
               "edge_response_result_type": process_field(fields[8]),
               "edge_result_type": process_field(fields[9]),
              
               # CMCD Fields (Common Media Client Data)
               "cmcd": {
                   "encoded_bitrate": safe_convert_int(fields[10]),
                   "buffer_length": safe_convert_float(fields[11]),
                   "buffer_starvation": process_field(fields[12]),
                   "content_id": process_field(fields[13]),
                   "object_duration": safe_convert_float(fields[14]),
                   "deadline": process_field(fields[15]),
                   "measured_throughput": safe_convert_int(fields[16]),
                   "next_object_request": process_field(fields[17]),
                   "next_range_request": process_field(fields[18]),
                   "object_type": process_field(fields[19]),
                   "playback_rate": safe_convert_float(fields[20]),
                   "requested_max_throughput": safe_convert_int(fields[21]),
                   "streaming_format": process_field(fields[22]),
                   "session_id": process_field(fields[23]),
                   "stream_type": process_field(fields[24]),
                   "startup": process_field(fields[25]),
                   "top_bitrate": safe_convert_int(fields[26]),
                   "version": process_field(fields[27])
               },
              
               # Edge and Request Fields
               "edge_mqcs": process_field(fields[28]),
               "sr_reason": process_field(fields[29]),
               "r_host": process_field(fields[30]),
               "x_host_header": process_field(fields[31]),
               "x_forwarded_for": process_field(fields[32]),
               "edge_request_id": process_field(fields[33]),
               "edge_detailed_result_type": process_field(fields[34]),
              
               # Timing and Performance Fields
               "time_to_first_byte": safe_convert_float(fields[35]),
               "time_taken": safe_convert_float(fields[36]),
              
               # SSL/TLS Fields
               "ssl_protocol": process_field(fields[37]),
               "ssl_cipher": process_field(fields[38]),
              
               # Content Range and Type Fields
               "range": {
                   "start": safe_convert_int(fields[39]),
                   "end": safe_convert_int(fields[40])
               },
               "content_type": process_field(fields[41]),
               "content_length": safe_convert_int(fields[42]),
              
               # Byte Transfer Fields
               "bytes_sent": safe_convert_int(fields[43]),
               "server_ip": process_field(fields[44]),
              
               # Distribution Fields
               "distribution": {
                   "id": process_field(fields[45]),
                   "dns_name": process_field(fields[46])
               },
              
               # Origin Fields
               "origin": {
                   "lbl": process_field(fields[47]),
                   "fbl": process_field(fields[48])
               },
              
               # Field Level Encryption Fields
               "fle": {
                   "status": process_field(fields[49]),
                   "encrypted_fields": process_field(fields[50])
               },
              
               # Request Details Fields
               "uri_query": process_field(fields[51]),
               "protocol_version": process_field(fields[52]),
               "protocol": process_field(fields[53]),
               "host": process_field(fields[54]),
               "headers_count": safe_convert_int(fields[55]),
               "headers": process_field(fields[56]),
               "header_names": process_field(fields[57]),
               "cookie": process_field(fields[58]),
               "bytes_received": safe_convert_int(fields[59]),
               "accept_encoding": process_field(fields[60]),
               "accept": process_field(fields[61]),
              
               # Cache and Client Fields
               "cache_behavior_path_pattern": process_field(fields[62]),
               "client": {
                   "port": safe_convert_int(fields[63]),
                   "ip_version": process_field(fields[64]),
                   "country": process_field(fields[65])
               },
               "asn": process_field(fields[66])
           }
          
           # Convert to JSON string and encode in base64
           json_str = json.dumps(transformed_log)
           encoded_data = base64.b64encode(json_str.encode('utf-8')).decode('utf-8')
          
           output_record = {
               'recordId': record['recordId'],
               'result': 'Ok',
               'data': encoded_data
           }
          
           logger.info(f"Processed record successfully: {json_str}")
           output.append(output_record)
          
       except Exception as e:
           logger.error(f"Error processing record: {str(e)}")
           logger.error(f"Raw record data: {record['data']}")
           output_record = {
               'recordId': record['recordId'],
               'result': 'ProcessingFailed',
               'data': record['data']
           }
           output.append(output_record)
  
   return {'records': output}