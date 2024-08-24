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

