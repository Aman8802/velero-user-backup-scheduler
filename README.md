📦 Velero User Backup Scheduler
This project automates the creation of scheduled Velero backup configurations for multiple users in a Kubernetes cluster, specifically using OpenShift’s Data Protection (OADP) integration.

🎯 Objective
To distribute the backup of 367 user-specific namespaces (<username>-devspaces) evenly over a fixed maintenance window — from Friday 11 PM CT to Monday 4 AM CT — using Velero's Schedule kind YAML definitions.

📂 Key Components
users.txt
A text file containing a list of 367 user names (randomly generated or customized).

devspaces.yaml (Template)
A base Velero schedule template with placeholders:

<variable> → replaced with the username.

<will-be-replaced> → replaced with calculated cron schedule time.

generate_user_schedules.sh
Bash script that:

Calculates time distribution across 53 hours.

Determines how many users should be scheduled per hour.

Generates 367 user-specific YAML files using the template.

Output Folder: schedules/
Contains all generated YAML files like:
schedules/Aman-devspaces.yaml
schedules/Abhishek-devspaces.yaml


🛠️ Usage
chmod +x generate_user_schedules.sh
./generate_user_schedules.sh
All generated files will be available inside the schedules/ directory.

⏱️ Schedule Details
Backup Window: Friday 11 PM CT → Monday 4 AM CT
(Converted to UTC for Velero cron format: Saturday 4 AM UTC → Monday 9 AM UTC)

Cron Format Used: 0 <hour> * * <day_of_week>

📌 Example Generated YAML

apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: ocdev-oadp-aman-devspaces
  namespace: openshift-adp
spec:
  schedule: "0 5 * * 6"
  skipImmediately: false
  template:
    csiSnapshotTimeout: 72h
    defaultVolumesToRestic: true
    excludedNamespaces: []
    includedNamespaces:
      - aman-devspaces
    storageLocation: ocdev-oadp-data-protection-application-1
    ttl: 720h

🤝 Contributions
Feel free to fork and modify this for larger or different batch scheduling needs. Issues and pull requests are welcome!
