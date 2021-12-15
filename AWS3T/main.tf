provider "aws" {
  region  = "ap-southeast-1"
}
resource "aws_cloudformation_stack" "ThreeTier" {
  name = "BMX-Demo"
  template_body = <<STACK
{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Resources": {
    "BMXDemoVPC": {
      "Type": "AWS::EC2::VPC",
      "Properties": {
        "CidrBlock": "152.145.0.0/16",
        "InstanceTenancy": "default",
        "EnableDnsSupport": "true",
        "EnableDnsHostnames": "true",
        "Tags": [
          {
            "Key": "Name",
            "Value": "BMX-DEMO-VPC"
          }
        ]
      }
    },
    "BMXPubSub1": {
      "Type": "AWS::EC2::Subnet",
      "Properties": {
        "CidrBlock": "152.145.1.0/24",
        "AvailabilityZone": "ap-southeast-1",
        "VpcId": {
          "Ref": "BMXDemoVPC"
        },
        "Tags": [
          {
            "Key": "Name",
            "Value": "BMX-Public-Subnet-1"
          }
        ]
      }
    },
    "BMXPrivateSub1": {
      "Type": "AWS::EC2::Subnet",
      "Properties": {
        "CidrBlock": "152.145.2.0/24",
        "AvailabilityZone": "ap-southeast-1",
        "VpcId": {
          "Ref": "BMXDemoVPC"
        },
        "Tags": [
          {
            "Key": "Name",
            "Value": "BMX-Private-Subnet-1"
          }
        ]
      }
    },
	"BMXPrivateSub2": {
      "Type": "AWS::EC2::Subnet",
      "Properties": {
        "CidrBlock": "152.145.4.0/24",
        "AvailabilityZone": "ap-southeast-1",
        "VpcId": {
          "Ref": "BMXDemoVPC"
        },
        "Tags": [
          {
            "Key": "Name",
            "Value": "BMX-Private-Subnet-2"
          }
        ]
      }
    },
	"BMXPrivateSub11": {
      "Type": "AWS::EC2::Subnet",
      "Properties": {
        "CidrBlock": "152.145.11.0/24",
        "AvailabilityZone": "ap-southeast-1",
        "VpcId": {
          "Ref": "BMXDemoVPC"
        },
        "Tags": [
          {
            "Key": "Name",
            "Value": "BMX-Private-Subnet-11"
          }
        ]
      }
    },
    "BMXPubSub2": {
      "Type": "AWS::EC2::Subnet",
      "Properties": {
        "CidrBlock": "152.145.3.0/24",
        "AvailabilityZone": "ap-southeast-1",
        "VpcId": {
          "Ref": "BMXDemoVPC"
        },
        "Tags": [
          {
            "Key": "Name",
            "Value": "BMX-Public-Subnet-2"
          }
        ]
      }
    },
    "BMXDemoIGW": {
      "Type": "AWS::EC2::InternetGateway",
      "Properties": {
      }
    },
    "dopt0a3c8262": {
      "Type": "AWS::EC2::DHCPOptions",
      "Properties": {
        "DomainName": "ap-southeast-1.compute.internal",
        "DomainNameServers": [
          "AmazonProvidedDNS"
        ]
      }
    },
    "acl0afa8e6666c317ba0": {
      "Type": "AWS::EC2::NetworkAcl",
      "Properties": {
        "VpcId": {
          "Ref": "BMXDemoVPC"
        }
      }
    },
    "rtb07b15feb99358f927": {
      "Type": "AWS::EC2::RouteTable",
      "Properties": {
        "VpcId": {
          "Ref": "BMXDemoVPC"
        }
      }
    },
    "rtb096e771c13039ce5e": {
      "Type": "AWS::EC2::RouteTable",
      "Properties": {
        "VpcId": {
          "Ref": "BMXDemoVPC"
        }
      }
    },
    "rtb0010d9c3a46db09ed": {
      "Type": "AWS::EC2::RouteTable",
      "Properties": {
        "VpcId": {
          "Ref": "BMXDemoVPC"
        },
        "Tags": [
          {
            "Key": "Name",
            "Value": "BMX-Public-RT-2"
          }
        ]
      }
    },
    "BMXDemoCLB": {
      "Type": "AWS::ElasticLoadBalancing::LoadBalancer",
      "Properties": {
        "Subnets": [
          {
            "Ref": "BMXPubSub2"
          },
          {
            "Ref": "BMXPubSub1"
          }
        ],
        "HealthCheck": {
          "HealthyThreshold": "10",
          "Interval": "30",
          "Target": "HTTP:80/",
          "Timeout": "5",
          "UnhealthyThreshold": "2"
        },
        "ConnectionDrainingPolicy": {
          "Enabled": "true",
          "Timeout": "300"
        },
        "ConnectionSettings": {
          "IdleTimeout": "60"
        },
        "CrossZone": "true",
        "SecurityGroups": [
          {
            "Ref": "sgCLBSG"
          }
        ],
        "Listeners": [
          {
            "InstancePort": "80",
            "LoadBalancerPort": "80",
            "Protocol": "HTTP",
            "InstanceProtocol": "HTTP"
          }
        ]
      }
    },
    "asgBMXDEMOASG": {
      "Type": "AWS::AutoScaling::AutoScalingGroup",
      "Properties": {
        "AvailabilityZones": [
          "ap-southeast-1a",
          "ap-southeast-1b"
        ],
        "Cooldown": "300",
        "DesiredCapacity": "2",
        "HealthCheckGracePeriod": "300",
        "HealthCheckType": "EC2",
        "MaxSize": "2",
        "MinSize": "2",
        "VPCZoneIdentifier": [
          {
            "Ref": "BMXPubSub1"
          },
          {
            "Ref": "BMXPubSub2"
          }
        ],
        "LaunchConfigurationName": {
          "Ref": "lcBMXDemoLC"
        },
        "LoadBalancerNames": [
          {
            "Ref": "BMXDemoCLB"
          }
        ],
        "Tags": [
          {
            "Key": "Name",
            "Value": "BMX-DEMO-I",
            "PropagateAtLaunch": true
          }
        ],
        "TerminationPolicies": [
          "Default"
        ]
      }
    },
    "lcBMXDemoLC": {
      "Type": "AWS::AutoScaling::LaunchConfiguration",
      "Properties": {
        "ImageId": "ami-0b8fed2ae8510edd1",
        "InstanceType": "t3.large",
        "KeyName": "Amit-Linux",
		"AssociatePublicIpAddress" : "true",
        "SecurityGroups": [
          {
            "Ref": "sgWebServerPorts"
          }
        ],
        "BlockDeviceMappings": [
          {
            "DeviceName": "/dev/xvda",
            "Ebs": {
              "SnapshotId": "snap-05997e363375c4011",
              "VolumeSize": 8
            }
          }
        ]
      }
    },
    "rdsmydbinstance": {
      "Type": "AWS::RDS::DBInstance",
      "Properties": {
        "AllocatedStorage": "20",
        "AllowMajorVersionUpgrade": "false",
        "DBInstanceClass": "db.t2.micro",
        "Port": "3306",
        "StorageType": "gp2",
        "BackupRetentionPeriod": "0",
        "MasterUsername": "root",
        "MasterUserPassword": "MyPassword",
        "PreferredBackupWindow": "22:32-23:02",
        "PreferredMaintenanceWindow": "mon:02:52-mon:03:22",
        "DBName": "MyDatabase",
        "Engine": "mysql",
        "EngineVersion": "5.6.40",
        "LicenseModel": "general-public-license",
        "MultiAZ": "true",
        "DBSubnetGroupName": {
          "Ref": "dbsubnetdefaultBMXDemoVPC"
        },
        "VPCSecurityGroups": [
          {
            "Ref": "sgrdslaunchwizard"
          }
        ],
        "Tags": [
          {
            "Key": "workload-type",
            "Value": "other"
          }
        ]
      }
    },
    "dbsubnetdefaultBMXDemoVPC": {
      "Type": "AWS::RDS::DBSubnetGroup",
      "Properties": {
        "DBSubnetGroupDescription": "DB Subnet Group",
        "SubnetIds": [
          {
            "Ref": "BMXPrivateSub1"
          },
          {
            "Ref": "BMXPrivateSub2"
          }
        ]
      }
    },
    "sgWebServerPorts": {
      "Type": "AWS::EC2::SecurityGroup",
      "Properties": {
        "GroupDescription": "WebServerPorts",
        "VpcId": {
          "Ref": "BMXDemoVPC"
        }
      }
    },
    "sgCLBSG": {
      "Type": "AWS::EC2::SecurityGroup",
      "Properties": {
        "GroupDescription": "Secuirty group for Load Balancer",
        "VpcId": {
          "Ref": "BMXDemoVPC"
        }
      }
    },
    "sgrdslaunchwizard": {
      "Type": "AWS::EC2::SecurityGroup",
      "Properties": {
        "GroupDescription": "RDS Security Group",
        "VpcId": {
          "Ref": "BMXDemoVPC"
        }
      }
    },
    "scalingScaleGroupSize": {
      "Type": "AWS::AutoScaling::ScalingPolicy",
      "Properties": {
        "PolicyType": "TargetTrackingScaling",
        "StepAdjustments": [

        ],
		"TargetTrackingConfiguration": {
          "PredefinedMetricSpecification": {
            "PredefinedMetricType": "ASGAverageCPUUtilization"
          },
          "TargetValue": "80"
        },
        "AutoScalingGroupName": {
          "Ref": "asgBMXDEMOASG"
        }
      }
    },
    "alarmTargetTrackingBMXDEMOASGAlarmHigh7ddc2641eaa74ee6bbd184d0969121ed": {
      "Type": "AWS::CloudWatch::Alarm",
      "Properties": {
        "ActionsEnabled": "true",
        "AlarmDescription": "BMX-DEMO-ASG:policyName/Scale Group Size.",
        "ComparisonOperator": "GreaterThanThreshold",
        "EvaluationPeriods": "3",
        "MetricName": "CPUUtilization",
        "Namespace": "AWS/EC2",
        "Period": "60",
        "Statistic": "Average",
        "Threshold": "80.0",
        "AlarmActions": [
          {
            "Ref": "scalingScaleGroupSize"
          }
        ],
        "Dimensions": [
          {
            "Name": "AutoScalingGroupName",
            "Value": "BMX-DEMO-ASG"
          }
        ]
      }
    },
    "alarmTargetTrackingBMXDEMOASGAlarmLow7ecd8e97898d4db5bb08508c39eefda1": {
      "Type": "AWS::CloudWatch::Alarm",
      "Properties": {
        "ActionsEnabled": "true",
        "AlarmDescription": "Alarm for Target Tracking",
        "ComparisonOperator": "LessThanThreshold",
        "EvaluationPeriods": "15",
        "MetricName": "CPUUtilization",
        "Namespace": "AWS/EC2",
        "Period": "60",
        "Statistic": "Average",
        "Threshold": "56.0",
        "AlarmActions": [
          {
            "Ref": "scalingScaleGroupSize"
          }
        ],
        "Dimensions": [
          {
            "Name": "AutoScalingGroupName",
            "Value": "BMX-DEMO-ASG"
          }
        ]
      }
    },
    "acl3": {
      "Type": "AWS::EC2::NetworkAclEntry",
      "Properties": {
        "CidrBlock": "0.0.0.0/0",
        "Egress": "true",
        "Protocol": "-1",
        "RuleAction": "allow",
        "RuleNumber": "100",
        "NetworkAclId": {
          "Ref": "acl0afa8e6666c317ba0"
        }
      }
    },
    "acl4": {
      "Type": "AWS::EC2::NetworkAclEntry",
      "Properties": {
        "CidrBlock": "0.0.0.0/0",
        "Protocol": "-1",
        "RuleAction": "allow",
        "RuleNumber": "100",
        "NetworkAclId": {
          "Ref": "acl0afa8e6666c317ba0"
        }
      }
    },
    "subnetacl2": {
      "Type": "AWS::EC2::SubnetNetworkAclAssociation",
      "Properties": {
        "NetworkAclId": {
          "Ref": "acl0afa8e6666c317ba0"
        },
        "SubnetId": {
          "Ref": "BMXPubSub2"
        }
      }
    },
    "subnetacl3": {
      "Type": "AWS::EC2::SubnetNetworkAclAssociation",
      "Properties": {
        "NetworkAclId": {
          "Ref": "acl0afa8e6666c317ba0"
        },
        "SubnetId": {
          "Ref": "BMXPubSub1"
        }
      }
    },
    "subnetacl4": {
      "Type": "AWS::EC2::SubnetNetworkAclAssociation",
      "Properties": {
        "NetworkAclId": {
          "Ref": "acl0afa8e6666c317ba0"
        },
        "SubnetId": {
          "Ref": "BMXPrivateSub1"
        }
      }
    },
    "gw2": {
      "Type": "AWS::EC2::VPCGatewayAttachment",
      "Properties": {
        "VpcId": {
          "Ref": "BMXDemoVPC"
        },
        "InternetGatewayId": {
          "Ref": "BMXDemoIGW"
        }
      }
    },
    "subnetroute3": {
      "Type": "AWS::EC2::SubnetRouteTableAssociation",
      "Properties": {
        "RouteTableId": {
          "Ref": "rtb07b15feb99358f927"
        },
        "SubnetId": {
          "Ref": "BMXPubSub1"
        }
      }
    },
    "subnetroute5": {
      "Type": "AWS::EC2::SubnetRouteTableAssociation",
      "Properties": {
        "RouteTableId": {
          "Ref": "rtb0010d9c3a46db09ed"
        },
        "SubnetId": {
          "Ref": "BMXPubSub2"
        }
      }
    },
    "route2": {
      "Type": "AWS::EC2::Route",
      "Properties": {
        "DestinationCidrBlock": "0.0.0.0/0",
        "RouteTableId": {
          "Ref": "rtb07b15feb99358f927"
        },
        "GatewayId": {
          "Ref": "BMXDemoIGW"
        }
      },
      "DependsOn": "gw2"
    },
    "route4": {
      "Type": "AWS::EC2::Route",
      "Properties": {
        "DestinationCidrBlock": "0.0.0.0/0",
        "RouteTableId": {
          "Ref": "rtb0010d9c3a46db09ed"
        },
        "GatewayId": {
          "Ref": "BMXDemoIGW"
        }
      },
      "DependsOn": "gw2"
    },
    "dchpassoc2": {
      "Type": "AWS::EC2::VPCDHCPOptionsAssociation",
      "Properties": {
        "VpcId": {
          "Ref": "BMXDemoVPC"
        },
        "DhcpOptionsId": {
          "Ref": "dopt0a3c8262"
        }
      }
    },
    "ingress3": {
      "Type": "AWS::EC2::SecurityGroupIngress",
      "Properties": {
        "GroupId": {
          "Ref": "sgWebServerPorts"
        },
        "IpProtocol": "tcp",
        "FromPort": "80",
        "ToPort": "80",
        "CidrIp": "0.0.0.0/0"
      }
    },
    "ingress4": {
      "Type": "AWS::EC2::SecurityGroupIngress",
      "Properties": {
        "GroupId": {
          "Ref": "sgWebServerPorts"
        },
        "IpProtocol": "tcp",
        "FromPort": "22",
        "ToPort": "22",
        "CidrIp": "0.0.0.0/0"
      }
    },
    "ingress5": {
      "Type": "AWS::EC2::SecurityGroupIngress",
      "Properties": {
        "GroupId": {
          "Ref": "sgCLBSG"
        },
        "IpProtocol": "tcp",
        "FromPort": "80",
        "ToPort": "80",
        "CidrIp": "0.0.0.0/0"
      }
    },
    "ingress6": {
      "Type": "AWS::EC2::SecurityGroupIngress",
      "Properties": {
        "GroupId": {
          "Ref": "sgrdslaunchwizard"
        },
        "IpProtocol": "tcp",
        "FromPort": "3306",
        "ToPort": "3306",
        "CidrIp": "121.244.129.2/32"
      }
    },
    "egress2": {
      "Type": "AWS::EC2::SecurityGroupEgress",
      "Properties": {
        "GroupId": {
          "Ref": "sgWebServerPorts"
        },
        "IpProtocol": "-1",
        "CidrIp": "0.0.0.0/0"
      }
    },
    "egress3": {
      "Type": "AWS::EC2::SecurityGroupEgress",
      "Properties": {
        "GroupId": {
          "Ref": "sgCLBSG"
        },
        "IpProtocol": "-1",
        "CidrIp": "0.0.0.0/0"
      }
    },
	"LinuxAPPInstance1": {
            "Type": "AWS::EC2::Instance",
            "Properties": {
                "ImageId": "ami-0a669382ea0feb73a",
				"InstanceType": "t3.large",
				"KeyName": "Amit-Linux",
				"SubnetId": {
                    "Ref": "BMXPrivateSub1"
                },  
				"SecurityGroupIds": [
					{
						"Ref": "sgWebServerPorts"
					}
				],
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "App-Instance-1"
                    }
                ]
            }
    },
	"BastionHost": {
            "Type": "AWS::EC2::Instance",
            "Properties": {
                "ImageId": "ami-0a669382ea0feb73a",
				"InstanceType": "t3.large",
				"KeyName": "Amit-Linux",
				"NetworkInterfaces": [ {
					"AssociatePublicIpAddress": "true",
					"DeviceIndex": "0",
					"GroupSet": [{ "Ref" : "sgWebServerPorts" }],
					"SubnetId": { "Ref" : "BMXPubSub1" }
				} ],
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "BastionHost"
                    }
                ]
            }
    },
	"LinuxAPPInstance2": {
            "Type": "AWS::EC2::Instance",
            "Properties": {
                "ImageId": "ami-0a669382ea0feb73a",
				"InstanceType": "t3.large",
				"KeyName": "Amit-Linux",
				"SubnetId": {
                    "Ref": "BMXPrivateSub2"
                },
				"SecurityGroupIds": [
					{	
						"Ref": "sgWebServerPorts"
					}
				],
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "App-Instance-2"
                    }
                ]
            }
    },
    "egress4": {
      "Type": "AWS::EC2::SecurityGroupEgress",
      "Properties": {
        "GroupId": {
          "Ref": "sgrdslaunchwizard"
        },
        "IpProtocol": "-1",
        "CidrIp": "0.0.0.0/0"
      }
    }
  },
  "Outputs" : {
	"LoadBalancerDNSName" : {
    "Description": "The DNSName of the Load Balancer",  
    "Value" : { "Fn::GetAtt" : [ "BMXDemoCLB", "DNSName" ]}
		},
	"BastionHostIP" : {
	"Description": "IP Address of Bastion Host",  
    "Value" : { "Fn::GetAtt" : [ "BastionHost", "PublicIp" ]}
	}
	},
  "Description": "My BMX DEMO"
}
STACK
}
