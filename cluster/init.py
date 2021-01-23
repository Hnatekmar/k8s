import os
import subprocess
import time

if __name__ == '__main__':
    os.environ["TF_VAR_proxmox_url"] = f"https://{os.environ.get('hostname')}/api2/json"
    os.environ["TF_VAR_proxmox_username"] = os.environ.get("username")
    os.environ["TF_VAR_proxmox_password"] = os.environ.get("password")
    print("Provisioning vms")
    subprocess.Popen("terraform apply -auto-approve -var-file=config.tfvar".split(' '), env=os.environ).wait()
    # Wait for deployment to stabilize
    print("Waiting for deployment to stabilize")
    time.sleep(60)
    print("Wait over")
    """
    Create cluster
    """
    subprocess.Popen("ansible-playbook -u root -i inventory.ini install.yml".split(' '), env=os.environ).wait()
    subprocess.Popen("bash create_cluster.sh".split(' '), env=os.environ).wait()

