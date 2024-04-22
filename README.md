
## Build the image
```bash
docker compose build
```
## Initial setup

Open a terminal in the container :
```bash
docker compose run --rm -it mtw-server bash
```
Default values are provided for login and pwd, that need to changed before the first launch by running :
```bash
python set-mtw-admin.py --login <YOUR_ADMIN_LOGIN> --pwd <YOUR_ADMIN_PASSWORD>`
```
Edit the config file :
```bash
nano instance/conf/mtw-dist.ini
```
Modify the values for your personnal configuration, including `TARGET_YEAR`, `TARGET_LANG`, `TARGET_NS` etc.  
Save with CTRL + X, then Y.

Exit the container:
```bash
exit
```

## Run MTW
```bash
docker compose up -d
```
