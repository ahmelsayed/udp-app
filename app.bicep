targetScope = 'resourceGroup'
param location string = resourceGroup().location

resource appEnv 'Microsoft.App/managedEnvironments@2022-11-01-preview' = {
  name: 'aca-env'
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'azure-monitor'
    }
    workloadProfiles: [
      {
        name: 'consumption'
        workloadProfileType: 'Consumption'
      }
    ]
  }
}

resource shell 'Microsoft.App/containerApps@2022-11-01-preview' = {
  name: 'shell'
  location: location
  properties: {
    environmentId: appEnv.id
    workloadProfileName: 'consumption'
    configuration: {
      ingress: {
        external: true
        targetPort: 8376
        transport: 'http'
      }
    }
    template: {
      containers: [
        {
          name: 'cloudshell'
          image: 'docker.io/ahmelsayed/cloudshell:latest'
        }
        {
          name: 'udpserver'
          image: 'docker.io/ahmelsayed/udp-server:latest'
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}

resource udpclient 'Microsoft.App/containerApps@2022-11-01-preview' = {
  name: 'udpclient'
  location: location
  properties: {
    environmentId: appEnv.id
    workloadProfileName: 'consumption'
    configuration: {
      ingress: {
        external: true
        targetPort: 8080
        transport: 'http'
      }
    }
    template: {
      containers: [
        {
          name: 'udpclient'
          image: 'docker.io/ahmelsayed/udp-client:latest'
        }
        {
          name: 'udpserver'
          image: 'docker.io/ahmelsayed/udp-server:latest'
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}

output shellUrl string = 'https://${shell.properties.configuration.ingress.fqdn}'
output udpClient string = 'https://${udpclient.properties.configuration.ingress.fqdn}'
// output appId string = app.id
// output latestCreatedRevision string = app.properties.latestRevisionName
// output latestCreatedRevisionId string = '${app.id}/revisions/${app.properties.latestRevisionName}'
// output latestReadyRevision string = app.properties.latestReadyRevisionName
// output latestReadyRevisionId string = '${app.id}/revisions/${app.properties.latestReadyRevisionName}'
// output azAppLogs string = 'az containerapp logs show -n ${app.name} -g ${resourceGroup().name} --revision ${app.properties.latestRevisionName} --follow --tail 30'
// output azAppExec string = 'az containerapp exec -n ${app.name} -g ${resourceGroup().name} --revision ${app.properties.latestRevisionName} --command /bin/bash'
// output azShowRevision string = 'az containerapp revision show -n ${app.name} -g ${resourceGroup().name} --revision ${app.properties.latestRevisionName}'
