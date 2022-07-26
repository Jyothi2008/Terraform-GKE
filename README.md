# Deploying app using terraform and GCP  
Build app using docker and push it to GCR repo on my project on GCP oand deploy it on private kubernetes cluster controlled by private vm, all infrastructure have provisioned using terraform (IaC).
## Building the app 
### I built the app using docker by creating the following Dockerfile
![image](https://user-images.githubusercontent.com/104630009/180803787-be3a0e38-aa6f-4198-bfad-0f2d601bc50d.png)
- I built th app on alpine:python image to ignore installing python then installed the requirements and made sure that all envronment varibale are declared and expsed to the new image
- After building th image using dockerfile i created a new repo on google artifact to push my image on it but i needed first to tag the image then push it 
![image](https://user-images.githubusercontent.com/104630009/180766912-81864920-2dc5-4e0b-b7df-5301a314df7f.png)
## provisioning the infrastructue 
- I started with setting GCP as my provider 

![image](https://user-images.githubusercontent.com/104630009/180806715-d5b405f5-87ec-40c5-ab58-806512239f40.png)
- And upload my statefile on a bucket to be synchronized with the others 

![image](https://user-images.githubusercontent.com/104630009/180807017-00afc25c-7cf6-43c5-b11b-3ba0c0587783.png)
### Network
- I created a VPC with routing mode ragional as all my infrastructure will impelmented in the same region

![image](https://user-images.githubusercontent.com/104630009/180845657-eb89a9e0-ff54-4591-b254-ddd03fe13874.png)

- Subnet with CIDR range [10.0.1.24/24] in my VPC and name it management subnet 

![image](https://user-images.githubusercontent.com/104630009/180845957-9777b197-391a-4a3d-b391-b6feeca8e5d2.png)

- Subnet with CIDR range [10.0.2.24/24] in my VPC and name it restricted subnet with two secondry ip ranges for the cluster pods and cluster services 

![image](https://user-images.githubusercontent.com/104630009/180846280-564d5931-97d3-4078-bd01-897be67d6785.png)

- Then created the firewalll to accept only ssh connection on port 22 with a target to tag to assign it to my private subnet only and not the cluster

![image](https://user-images.githubusercontent.com/104630009/180830714-b23d4918-386e-49a7-a211-a0b8a9d51276.png)
- Then the router to assign it to the Nat gatway for the vpc

![image](https://user-images.githubusercontent.com/104630009/180831091-c9a8f5c0-5bea-4e8e-bf3b-30c84f5b4df6.png)
- And the Nat gatway to allow only managment subnet including my private instance to get its packages and updates 

![image](https://user-images.githubusercontent.com/104630009/180831599-2ae8749b-6e34-4263-af88-f1b90aa882b6.png)
### Service accounts
### I created a two service account one for my instance and one for the GKE cluster as the following
- The one attached to my instance have Role of container admin to have permissions to access my cluster 
![image](https://user-images.githubusercontent.com/104630009/180832720-8ecdd7b6-5c5f-4f8a-9245-19d44504be80.png)
- The one for my cluster have the Role of storage viwer to have permission to pull the images from my GCR repo
![image](https://user-images.githubusercontent.com/104630009/180833016-c90b6847-b723-4767-ada3-bc0d38650d27.png)
## Computing instance and GKE
### private VM
- Creating an instance in my managment subnet having tag [ssh] to allow the traffic on port 22 using my firewall and assign the service account to access the GKE and assign a strtup script to install gcloud and kubectl whicl i will discuss below 
![image](https://user-images.githubusercontent.com/104630009/180833348-48cce134-38c4-46c5-ad1d-29cb11657215.png)
### GKE 
- I created the GKE with in same region zone 'a' using variable 'region' in my VPC and defining the default created node pool to false to create my own pool but but the intial node count by 1 to create the master node in it 
![image](https://user-images.githubusercontent.com/104630009/180889728-1a055340-b996-4aaa-9b19-154dcb9dc134.png)
- ip allocation policy is where i define my pods and services IPs ranges are and this is what i have defined eariler in my restricted subnet as secondry IPs ranges
![image](https://user-images.githubusercontent.com/104630009/180890608-f4f817ea-65bb-4d8f-a31a-0649321f077e.png)
- configuring the private endpoints and nodes as true as make my cluster private and have no access from outside the subnet and assigning the master_ipv4_cidr_block with range of IPs does not overlap any IPs range of the cluster network to assign a private IP to ILB and my master node to be able to communicate with the worker nodes 
![image](https://user-images.githubusercontent.com/104630009/180891272-9a0916ef-34b1-495b-b9a9-ce85eb94270d.png)
- configure a master authorized network which is my managment subnet CIDR range to open the communication between the private VM and the master node to control the cluster from it 
![image](https://user-images.githubusercontent.com/104630009/180891330-9fb59138-7b88-4544-b430-bab4c6d5bb02.png)
- creating my worker node pool with name node pool in the same zone where is my cluster and assign the service account which allow give permission Role storage.Voewer to allow the nodes to pull images on GCR or Artifact repos and setting the scoop to be on all  platform
![image](https://user-images.githubusercontent.com/104630009/180891644-114dec81-1af3-4151-9f60-4392233a7ed0.png)
## provision the infrastructure
- Now i can provision this infrastructure using terraform command `terraform apply`
![image](https://user-images.githubusercontent.com/104630009/180893072-e79b58cf-5b5e-415c-8dbe-1a01f7c03d50.png)
## setting up the VM 
### startup script 
- I script the following bash script to add gcloud repo then install the gcloud and intiate it and add the kubectl repo and update the packages then install it 
![image](https://user-images.githubusercontent.com/104630009/180892634-2c54d4ea-6cb1-4729-8021-f636e5bc7423.png)
### ssh to the private VM 
- Now i need to ssh the private VM to setup my configuration to my cluster and script the deployment and service yaml files to deploy my app and expose it 
- So first i made sure that the user i use is authorized to access my project and resources 
![image](https://user-images.githubusercontent.com/104630009/180893970-a4460fc0-c801-4bd8-833a-392aacbe9907.png)
- next i ssh my private VM using the `gcloud compute ssh` command
![image](https://user-images.githubusercontent.com/104630009/180894134-f1dadba5-a8f6-48c4-a0eb-4b4d2f8b6d9f.png)
- after ensure that kubectl and gcloud is installed
- ![image](https://user-images.githubusercontent.com/104630009/180894344-71084e61-a0a4-41dd-a813-0d59a442bc1f.png)
![image](https://user-images.githubusercontent.com/104630009/180894409-20ff8256-dd4a-4573-b5fa-615a1f3f24c2.png)
- i configured my cluster using `gcloud container cluster get-credetintials` 
![image](https://user-images.githubusercontent.com/104630009/180894809-189a0a3c-742d-4221-a4ae-675c3bafc262.png)
- Now i can write my deployment and service yaml file to deploy them, so did i 
![image](https://user-images.githubusercontent.com/104630009/180894990-8d9cd0e5-37ec-4707-88ce-7baec5b60203.png)
![image](https://user-images.githubusercontent.com/104630009/180895003-03969ed7-5924-48b7-810c-ff19bd261bbd.png)
- Now deploy them using `kubectl apply`
![image](https://user-images.githubusercontent.com/104630009/180895235-336cf6e2-b902-4da2-9ceb-2b0ba1f097e1.png)
![image](https://user-images.githubusercontent.com/104630009/180895369-a9dd8892-4a9b-4307-aaa2-a09212a677fa.png)
## THE END 
### now ckecking that everything is working as it should be 
- my pods are working correctly 
![image](https://user-images.githubusercontent.com/104630009/180895527-0bbbe613-68f8-4882-9477-11fdc997e0f3.png)
- my service having its external IP and its selector is set to my pods tag 
![image](https://user-images.githubusercontent.com/104630009/180895774-ffbde289-c230-4030-8ede-0278b6749f66.png) 
- and its endpoint are my pods private IPs on port 8000
![image](https://user-images.githubusercontent.com/104630009/180895595-993748ca-67b4-4bf0-81e8-09d255d4bf0d.png)
- testing the LB external IP with port 8000 on my browser 
![image](https://user-images.githubusercontent.com/104630009/180895962-8e946c57-e14f-4c9a-89f7-ace3c6b9a180.png)
- And everything is working perfectly!
