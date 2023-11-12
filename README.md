# Example

This example connects two VPC using the VPC endpoint service

## Procedure

- On Provider Side:
  - Create a VPC Endpoint Service
  - Select the NLB
  - Copy the Service Name
- On Comsumer Side: 
  - Create a VPC Endpoint
  - Select Service Name
  - Create the Endpoint
  - Copy one Domain name of Endpoint
- On Provider Side
  - Accept the request
- On consumer side
  - Make a curl from the  consumer machine to the consumer VPCE
  - you should see the network connection to be established to the provider machines