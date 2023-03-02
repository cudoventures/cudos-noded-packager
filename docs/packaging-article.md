# Cudos Behind the Curtain

The Cudos mainnet blockchain network was recently forked to version v1.1 in it's first mainnet software upgrade. This upgrade saw a significant change in the way the daemon software is installed and laid out in the operating system. This article is intended to explain the change and look at some of the technologies being used.

## The History

The Cudos Network mainnet launch in June 2022 was the culmination of several years hard work by Cudo Ventures and our developers. By this time the code had been tested and pushed and stretched in as many ways as we could come up with. The execution of these tests was done on our private and public testnet, but also prior to that, by our developers using single node "Dev Networks". In order to provide the developers with a mechanism for using these develeopment networks a system of docker containers and docker-compose processes was created. While this was perfect for the development use case, it was less well suited to being installed on user machines. It added considerably to the installation complexity and frustrated ongoing updates and niche configuration needs. It was decided that we needed to rethink the install and maintenance experience.


