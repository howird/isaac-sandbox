# isaac-sandbox
sandbox to play with nvidia's isaac sim / lab tools

## Set Up for Docker (Streaming)

### On Remote Machine (Streaming Server)

#### Pre-Requisites

- Docker Installation (check with: `docker run hello-world`)
- [NVIDIA Container Toolkit](https://github.com/NVIDIA/nvidia-docker). (check: `nvidia-container-cli -V`)
- A [NGC Account](https://docs.nvidia.com/ngc/ngc-overview/index.html#registering-activating-ngc-account) and an [NGC API Key](https://docs.nvidia.com/ngc/ngc-overview/index.html#generating-api-key)
  - See this [this page](https://docs.nvidia.com/launchpad/ai/base-command-coe/latest/bc-coe-docker-basics-step-02.html)
  - Make an account and configure/verify your docker credentials locally with: (`docker login nvcr.io`)

#### Set Up

- Clone this repository:
```bash
git clone git@github.com:saeejithnair/nvsynth.git
cd nvsynth
```

- Setup your environment variables:
```bash
./initialize.sh
```

- Build the Isaac Sim docker container:
```bash
docker compose build
```

### On Your Local Machine (Streaming Client)

  - A chromium-based browser (Google Chrome, Chromium, Microsoft Edge)

## Usage for Docker (Streaming)

### On Remote Machine (Streaming Server)

- There are currently two usages of this docker container:
  - (1) the first (default) is starting the docker container and running scripts/the app manually
    - this can be done via the provided vscode devcontainer as well
  - (2) the second is simply running the base `isaac-sim` app
  - (3) the third is running our custom python scripts in this repo

#### (1) Running Isaac Sim Manually

- Start the docker container:
```bash
docker compose up -d
```

- Enter the container
```bash
docker compose exec isaac-sandbox bash
```

- Run the a command to start the Isaac-Sim app
```bash
/isaac-sim/runheadless.webrtc.sh
# OR
python scripts/gen_random_scenes.py
```

#### (2) Running the Base Isaac Sim App

- For the basic usage of the app, supply the following command to the service in the `docker-compose.yml`
```yaml
services:
  isaac-sim:
    command: ["/isaac-sim/runheadless.webrtc.sh"]
```

- You can also add arguments by appending them to the list:
```yaml
services:
  isaac-sim:
    command: [
      "/isaac-sim/runheadless.webrtc.sh",
      "--/app/livestream/logLevel=debug", # set livestream loglevels
      "--/app/window/dpiScaleOverride=1.5", # rescale livestream window UI
      "--/exts/omni.services.transport.server.http/port=8045", # change WebRTC server port
      "--/app/livestream/port=48010", # change livestream data por<tab>
    ]
```

- Then we can start our docker container with
```bash
docker compose up
```

#### (3) Running Isaac Sim via a Python Script

- To run our scripts, we also modify the `docker-compose.yml` file by changing the target of our `Dockerfile` to `nvsynth` and add the command `"python path/to/script.py"`:
```yaml
services:
  isaac-sim:
    command: ["python", "scripts/gen_random_scenes.py"] # path of script is relative to repo root
```

- Then we can start our docker container with
```bash
docker compose up
```

### On Your Local Machine (Streaming Client)

- Now that your the Omniverse Streamer is running on the remote machine, we can view the stream on our local machine

- Open a local terminal and forward the necessary ports on the remote machine to your client machine:
  - if you are using a vscode devcontainer, it may already be forwarding these ports for you automatically
  - this will give you the error: `bind [127.0.0.1]:8211: Address already in use`
  - in this case, you do not have to run this command
```bash
ssh -NL 8211:localhost:<livestream client port> -L 49100:localhost:<livestream data port> <username>@<ip of remote machine>
```

- Go to a browser and open:
  - it may have to be chromium-based, firefox did not work for me

### Debugging

- On the remote machine you can check that the correct ports are being used with: 
```bash
docker compose exec isaac-sandbox bash -c "lsof -nP -iTCP -sTCP:LISTEN"
# You should see an output similar to this:
COMMAND PID USER   FD   TYPE   DEVICE SIZE/OFF NODE NAME
kit      21 root  258u  IPv4 43127461      0t0  TCP *:49100 (LISTEN)
kit      21 root  277u  IPv4 43151425      0t0  TCP *:8211 (LISTEN)
```

- On your client machine try and ping the ports that you have forwarded on your machine
  - you should get `404 Not Found` or `501 Not Implemented` errors, but you should not be getting `failed: Connection refused.`
```bash
wget localhost:8211 # 404 Not Found
wget localhost:49100 # 501 Not Implemented
```

- You can also monitor the logs in the container with:
```bash
# filename is in format `kit_YYYYMMDD_HHMMSS.log` use tab to complete
# inside docker container
tail -f /home/user/.nvidia-omniverse/logs/Kit/Isaac-Sim/2023.1/kit_
# outside of docker container
tail -f ~/docker/isaac-sim/logs/Kit/Isaac-Sim/2023.1/kit_
```

- If you get any permissions errors when running isaac-sim, check if there are files/folders not owned by you with:
  - If this does not resolve anything, and you are still running into permissions errors, there may be directories, that must be created as a non-root user before starting isaac-sim
  - Try doing so using the [initialize script](./initialize.sh) and mapping them onto the docker container using the [docker config](./docker-compose.yml), then submit a PR
```bash
find ~/.docker/isaac-sim/ ! -user $(whoami) -print
# If files are printed out, try running: chown -R $(id -u):$(id -g) ~/.docker/isaac-sim/
```

- Isaac sim docs:
```
python3 -m http.server -d /isaac-sim/docs/py <port>
```
