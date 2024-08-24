# CloudPros 3-Tier Architecture

This architecture demonstrates an implementation of a typical 3-tier application, while considering some of AWS' best practices.

<p text-align=center>
<img src=./architecture.drawio.png width=90% >
</p>

## Considerations

### 1. High-Availability:
In order to ensure that my architecture was highly-available, I ensured that it `spanned over 2 availability zones(AZ)` within a region. This would mean that if, for any reason, there was a problem in one  AZ, then our application will remain online because the other AZ would remain up. 

### 2. Scalability:
In order to ensure that our servers scaled based on demand, I configured `CloudWatch Alarms to monitor the EC2 Autoscaling Group and scale the servers in or out based on CPU usage`. These alarms were configured to handle these scaling in/out based on defined scaling policies. 
<br/>
The benefit of this is that we can `save cost` by scaling down the number of servers used when cpu usage is low and scale up to meet demand when cpu usage is high. 


## Extra Notes ...
### A. NAT Gateway:
The NAT gateways were provisioned and connected to the internet gateway. This ensure that the servers in the private subnet could reach the internet if needed. <br/>
In the architecture, we have one NAT gateway per AZ to be able to handle situations where one AZ goes down. Although two NATs will cost slightly, more if we did cross-AZ NAT connections, that would also have its associated cost. So the method chosen is recommended for high-availability.

### B. LoadBalancing:
Load balancing was configured to ensure that incoming traffic can be distributed appropriately among the provisioned servers. The load balancer is scalable by design, so I provisioned just one.

### C. DataBase Replication:
Configuring RDS replication in a multi-AZ architecture on AWS `ensures high availability and data redundancy`. In this setup, RDS automatically replicates data to a standby instance in a different Availability Zone. This redundancy `provides automatic failover in case of an infrastructure issue`, minimizing downtime and maintaining service continuity. Additionally, it ensures data durability by having copies in multiple locations, protecting against data loss due to hardware failures or other disruptions. This approach is crucial for mission-critical applications that require consistent uptime and data integrity.
 

<br/>
<br/>
<br/>

> # Important!
> We typically don't want to push our `.tfvars` files to public repositories, but I pushed  mine since this project was for demonstration purpose only.