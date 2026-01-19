import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

const FeatureList = [
  {
    title: 'Secure by design',
    Svg: require('@site/static/img/datalock.svg').default,
    description: (
      <>
        Encryption and decryption happen entirely on the client, so secrets never leave
        the app unprotected. The backend never sees raw passwords or keys and only
        processes already-encrypted data.
      </>
    ),
  },
  {
    title: 'Powered by open source',
    Svg: require('@site/static/img/open-source.svg').default,
    description: (
      <>
        Fully open source and auditable from end to end. Review the SSH and SFTP code,
        contribute fixes or features, and adapt the client to your own workflows without
        being locked into a proprietary ecosystem.
      </>
    ),
  },
  {
    title: 'Self hosted',
    Svg: require('@site/static/img/server.svg').default,
    description: (
      <>
        Run the coordination and sync services on your own infrastructure, so host
        lists, keys, and connection history never leave your environment. Keep full
        control over where your data lives and how it is secured.
      </>
    ),
  },
];

function Feature({Svg, title, description}) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        <Svg className={styles.featureSvg} role="img" />
      </div>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures() {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
