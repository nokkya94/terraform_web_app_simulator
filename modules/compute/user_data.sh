#!/bin/bash
echo "ALB DNS: ${alb_dns_name}" > /tmp/alb_info.txt
echo "Web application setup complete. Access it at http://${alb_dns_name}" > /tmp/setup_info.txt