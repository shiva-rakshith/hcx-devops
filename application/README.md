## Application deployment codebase


### Folder structure

```
./application
  |-- ansible       # Contains the VM application deployment code
  |-- dockerfile    # Contains the dockerfiles for creating infrastructure dependencies
  |-- helm          # Contains the charts to deploy apps to kuberntes
  `-- pipelines     # Jenkinsfiles to orchestrate the jenkins deployment/provisioning
```

