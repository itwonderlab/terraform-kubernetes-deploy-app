# Copyright (C) 2018 - 2020 IT Wonder Lab (https://www.itwonderlab.com)
#
# This software may be modified and distributed under the terms
# of the MIT license.  See the LICENSE file for details.

# -------------------------------- WARNING --------------------------------
# IT Wonder Lab's best practices for infrastructure include modularizing 
# Terraform configuration. 
# In this example, we define everything in a single file. 
# See other tutorials for Terraform best practices for Kubernetes deployments.
# -------------------------------- WARNING --------------------------------

terraform {
  required_version = "~> 0.12" #cannot contain interpolations. Means requiered version >= 0.12 and < 0.13
}

#-----------------------------------------
# Default provider: Kubernetes
#-----------------------------------------

provider "kubernetes" {
  #Context to choose from the config file.
  config_context = "kubernetes-admin@ditwl-k8s-01"
  version = "~> 1.12"
}


#-----------------------------------------
# KUBERNETES DEPLOYMENT COLOR APP
#-----------------------------------------

resource "kubernetes_deployment" "color" {
    metadata {
        name = "color-blue-dep"
        labels = {
            app   = "color"
            color = "blue"
        } //labels
    } //metadata
    
    spec {
        selector {
            match_labels = {
                app   = "color"
                color = "blue"
            } //match_labels
        } //selector

        #Number of replicas
        replicas = 3

        #Template for the creation of the pod
        template { 
            metadata {
                labels = {
                    app   = "color"
                    color = "blue"
                } //labels
            } //metadata

            spec {
                container {
                    image = "itwonderlab/color"   #Docker image name
                    name  = "color-blue"          #Name of the container specified as a DNS_LABEL. Each container in a pod must have a unique name (DNS_LABEL).
                    
                    #Block of string name and value pairs to set in the container's environment
                    env { 
                        name = "COLOR"
                        value = "blue"
                    } //env
                    
                    #List of ports to expose from the container.
                    port { 
                        container_port = 8080
                    }//port          
                    
                    resources {
                        limits {
                            cpu    = "0.5"
                            memory = "512Mi"
                        } //limits
                        requests {
                            cpu    = "250m"
                            memory = "50Mi"
                        } //requests
                    } //resources
                } //container
            } //spec
        } //template
    } //spec
} //resource

#-------------------------------------------------
# KUBERNETES DEPLOYMENT COLOR SERVICE NODE PORT
#-------------------------------------------------

resource "kubernetes_service" "color-service-np" {
  metadata {
    name = "color-service-np"
  } //metadata
  spec {
    selector = {
      app = "color"
    } //selector
    session_affinity = "ClientIP"
    port {
      port      = 8080 
      node_port = 30085
    } //port
    type = "NodePort"
  } //spec
} //resource

