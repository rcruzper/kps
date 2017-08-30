# kps :whale:

Command-line tool to execute most common actions with kubernetes pods via kubectl and [fzf](https://github.com/junegunn/fzf)

## Requirements

- [brew](http://brew.sh/index_es.html)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [fzf](https://github.com/junegunn/fzf)

## Installation

```shell
$ brew tap rcruzper/homebrew-tools
$ brew install kps
```

## Usage

kps accepts all kubectl [params](https://kubernetes.io/docs/user-guide/kubectl/) (i.e. `kps -n dev` will show all pods running on the dev namespace )

kps allows to execute those actions on each pod:

- ```CTRL-i``` inspects the pod `kubectl decribe pod <podName>`
- ```CTRL-s``` stops the pod `kubectl delete pod <podName>`
- ```CTRL-l``` shows pod logs `kubectl logs -f <podName>`
- ```CTRL-e``` opens a terminal into a pod `kubectl exec -it <podName> -- /bin/sh`
- ```Enter``` copies pod name into the clipboard
