# Deploying app using terraform and GCP  
build app using docker and push it on GCR repo on my project on GCP oand deploy it on kubernetes cluster provisioned using terraform (IaC) on google cloud platform
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
- i created a VPC and 2 subnets coded as the following
![image](https://user-images.githubusercontent.com/104630009/180805524-9f316268-4244-477f-aab4-1f11e735c187.png)
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
### Computing instance and GKE
- Creating an instance in my managment subnet having tag [ssh] to allow the traffic on port 22 using my firewall and assign the service account to access the GKE 
![image](https://user-images.githubusercontent.com/104630009/180833348-48cce134-38c4-46c5-ad1d-29cb11657215.png)
- 
