ansible all -m ping
```

You should see green "SUCCESS" for all three machines:
```
control-machine | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
server1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
server2 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}