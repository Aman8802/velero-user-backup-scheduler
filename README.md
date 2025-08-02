# velero-user-backup-scheduler
📦 Velero User Backup Scheduler
This project automates the creation of scheduled Velero backup YAML files for multiple user namespaces in a Kubernetes (OpenShift) cluster using OADP (OpenShift API for Data Protection).

✅ Goal
Distribute backups for 367 users over a defined maintenance window:
Friday 11 PM CT to Monday 4 AM CT (total 53 hours).
Each user namespace follows the naming format: <username>-devspaces.

🧩 How It Works
users.txt — Contains the list of user names.

devspaces.yaml — A template Velero Schedule YAML with placeholders.

generate_user_schedules.sh — A script that:

Calculates how many users to schedule per hour.

Generates personalized YAML files for each user with unique cron schedules.

schedules/ — Output folder containing YAML files like:

aman-devspaces.yaml

rahul-devspaces.yaml

...

🕓 Cron Scheduling Logic
The 53-hour window is converted to UTC and split evenly across all users. Each generated file uses a unique schedule: cron expression ensuring balanced backup load per hour.

🚀 Usage
bash
Copy
Edit
chmod +x generate_user_schedules.sh
./generate_user_schedules.sh
All Velero schedule files will be created inside the schedules/ directory.

🛠 Example YAML Output
yaml
Copy
Edit
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: ocdev-oadp-aman-devspaces
  namespace: openshift-adp
spec:
  schedule: "0 5 * * 6"
  ...
