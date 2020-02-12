local config = import 'generic-operator/config';
{
  local defaultConfig = self,

  name: config.metadata.name,
  namespace: config.metadata.namespace,
  thanosVersion: config.spec.thanos.version,
  thanosImage: config.spec.thanos.image + ':' + defaultConfig.thanosVersion,
  objectStorageConfig: {
    name: config.spec.thanos.objectStoreConfigSecret,
    key: config.spec.thanos.objectStoreConfigKey,
  },

  hashrings: config.spec.thanos.hashrings,

  compact: {
    image: defaultConfig.thanosImage,
    version: defaultConfig.thanosVersion,
    objectStorageConfig: defaultConfig.objectStorageConfig,
    retentionResolutionRaw: '14d',
    retentionResolution5m: '1s',
    retentionResolution1h: '1s',
    volumeClaimTemplate: {
      spec: {
        accessModes: ['ReadWriteOnce'],
        resources: {
          requests: {
            storage: '50Gi',
          },
        },
      },
    },
  },

  thanosReceiveController: {
    local trcConfig = self,
    version: config.spec.thanos.receiveController.version,
    image: config.spec.thanos.receiveController.image + ':' + trcConfig.version,
    hashrings: defaultConfig.hashrings,
  },

  receivers: {
    image: defaultConfig.thanosImage,
    version: defaultConfig.thanosVersion,
    hashrings: defaultConfig.hashrings,
    objectStorageConfig: defaultConfig.objectStorageConfig,
    volumeClaimTemplate: {
      spec:config.spec.thanos.receivers.pvcSpec,
    },
  },

  rule: {
    image: defaultConfig.thanosImage,
    version: defaultConfig.thanosVersion,
    objectStorageConfig: defaultConfig.objectStorageConfig,
    volumeClaimTemplate: {
      spec: config.spec.thanos.rule.pvcSpec,
    },
  },

  store: {
    image: defaultConfig.thanosImage,
    version: defaultConfig.thanosVersion,
    objectStorageConfig: defaultConfig.objectStorageConfig,
    volumeClaimTemplate: {
      spec: config.spec.thanos.store.pvcSpec,
    },
  },

  query: {
    image: defaultConfig.thanosImage,
    version: defaultConfig.thanosVersion,
  },

  queryCache: {
    local qcConfig = self,
    replicas: config.spec.thanos.queryCache.replicas,
    version: config.spec.thanos.queryCache.version,
    image: config.spec.thanos.queryCache.image + ':' + qcConfig.version,
  },
}
