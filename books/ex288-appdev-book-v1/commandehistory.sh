   78  2025-05-31 17:03:38.178 | [AUDIT   ] CWWKZ0022W: Application decisioncenter non démarrée en 30,000 secondes.
   79  2025-05-31 17:03:39.475 | [AUDIT   ] CWWKT0016I: Application Web disponible, (default_host) : http://52918eda1be9:9060/decisioncenter/
   80  2025-05-31 17:03:40.476 |  2025-05-31 17:03:40.476 |  _____  ______   ____    ____     ___   ______   ____    ____
   81  2025-05-31 17:03:40.476 | |_   _||_   _ \ |_   \  /   _|  .'   `.|_   _ `.|_   \  /   _|
   82  2025-05-31 17:03:40.476 |   | |    | |_) |  |   \/   |   /  .-.  \ | | `. \ |   \/   |
   83  2025-05-31 17:03:40.476 |   | |    |  __'.  | |\  /| |   | |   | | | |  | | | |\  /| |
   84  2025-05-31 17:03:40.476 |  _| |_  _| |__) |_| |_\/_| |_  \  `-'  /_| |_.' /_| |_\/_| |_
   85  2025-05-31 17:03:40.476 | |_____||_______/|_____||_____|  `.___.'|______.'|_____||_____|
   86  2025-05-31 17:03:40.476 |  2025-05-31 17:03:40.476 | :: Decision Center - Business Console - 8.11.1.0.1 :: built with Spring Boot (v2.6.7)
   87  2025-05-31 17:03:41.267 | [AVERTISSEMENT] You are asking Spring Security to ignore Ant [pattern='/**', OPTIONS]. This is not recommended -- please use permitAll via HttpSecurity#authorizeHttpRequests instead.
   88  2025-05-31 17:03:41.525 | [AVERTISSEMENT] Exception encountered during context initialization - cancelling refresh attempt: org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'decisionCenterApi' defined in class path resource [com/ibm/rules/decisioncenter/api/SwaggerConfig.class]: Bean instantiation via factory method failed; nested exception is org.springframework.beans.BeanInstantiationException: Failed to instantiate [io.swagger.v3.oas.models.OpenAPI]: Factory method 'decisionCenterApi' threw exception; nested exception is java.time.format.DateTimeParseException: Text '2021-Jan-20 10:30:00 GMT' could not be parsed at index 5
   89  2025-05-31 17:03:41.734 | [ERREUR  ] Application run failed
   90  2025-05-31 17:03:41.734 | Error creating bean with name 'decisionCenterApi' defined in class path resource [com/ibm/rules/decisioncenter/api/SwaggerConfig.class]: Bean instantiation via factory method failed; nested exception is org.springframework.beans.BeanInstantiationException: Failed to instantiate [io.swagger.v3.oas.models.OpenAPI]: Factory method 'decisionCenterApi' threw exception; nested exception is java.time.format.DateTimeParseException: Text '2021-Jan-20 10:30:00 GMT' could not be parsed at index 5
   91  2025-05-31 17:03:42.274 | [AUDIT   ] CWWKZ0012I: L'application decisioncenter-api n'a pas été démarrée.
   92  2025-05-31 17:03:42.279 | [AUDIT   ] CWWKT0017I: Application Web supprimée (default_host) : http://52918eda1be9:9060/decisioncenter-api/
   93  2025-05-31 17:03:53.195 | WARNING: An illegal reflective access operation has occurred
   94  2025-05-31 17:03:53.195 | WARNING: Illegal reflective access by org.eclipse.emf.ecore.xmi.impl.XMLHandler (file:/opt/ol/wlp/usr/servers/defaultServer/apps/expanded/decisioncenter.war/WEB-INF/lib/ecore-xmi-2.5.0.v201005211846.jar) to method com.sun.org.apache.xerces.internal.parsers.AbstractSAXParser$LocatorProxy.getEncoding()
   95  2025-05-31 17:03:53.195 | WARNING: Please consider reporting this to the maintainers of org.eclipse.emf.ecore.xmi.impl.XMLHandler
   96  2025-05-31 17:03:53.195 | WARNING: Use --illegal-access=warn to enable warnings of further illegal reflective access operations
   97  2025-05-31 17:03:53.195 | WARNING: All illegal access operations will be denied in a future release
   98  2025-05-31 17:03:57.053 | [AVERTISSEMENT] Trusting all certificates configured for Client@e35639bc[provider=null,keyStore=null,trustStore=null]
   99  2025-05-31 17:03:57.053 | [AVERTISSEMENT] No Client EndPointIdentificationAlgorithm configured for Client@e35639bc[provider=null,keyStore=null,trustStore=null]
  100  2025-05-31 17:03:57.203 | [AVERTISSEMENT] Trusting all certificates configured for Client@82301390[provider=null,keyStore=null,trustStore=null]
  101  2025-05-31 17:03:57.204 | [AVERTISSEMENT] No Client EndPointIdentificationAlgorithm configured for Client@82301390[provider=null,keyStore=null,trustStore=null]
  102  2025-05-31 17:03:57.227 | [AVERTISSEMENT] Not all security plugins configured!  authentication=disabled authorization=disabled.  Solr is only as secure as you make it. Consider configuring authentication/authorization before exposing Solr to users internal or external.  See https://s.apache.org/solrsecurity for more info
  103  2025-05-31 17:03:57.905 | [AVERTISSEMENT] Solr loaded a deprecated plugin/analysis class [solr.WordDelimiterFilterFactory]. Please consult documentation how to replace it accordingly.
  104  2025-05-31 17:03:57.934 | [AVERTISSEMENT] Solr loaded a deprecated plugin/analysis class [solr.TrieIntField]. Please consult documentation how to replace it accordingly.
  105  2025-05-31 17:03:57.936 | [AVERTISSEMENT] Solr loaded a deprecated plugin/analysis class [solr.TrieFloatField]. Please consult documentation how to replace it accordingly.
  106  2025-05-31 17:03:57.938 | [AVERTISSEMENT] Solr loaded a deprecated plugin/analysis class [solr.TrieLongField]. Please consult documentation how to replace it accordingly.
  107  2025-05-31 17:03:57.940 | [AVERTISSEMENT] Solr loaded a deprecated plugin/analysis class [solr.TrieDoubleField]. Please consult documentation how to replace it accordingly.
  108  2025-05-31 17:03:57.941 | [AVERTISSEMENT] Solr loaded a deprecated plugin/analysis class [solr.TrieDateField]. Please consult documentation how to replace it accordingly.
  109  2025-05-31 17:03:57.945 | [AVERTISSEMENT] Solr loaded a deprecated plugin/analysis class [solr.SynonymFilterFactory]. Please consult documentation how to replace it accordingly.
  110  2025-05-31 17:04:02.632 | [AUDIT   ] CWWKZ0001I: Application decisioncenter démarrée en 54,457 secondes.
  111  2025-07-21 17:47:31.818 |  2025-07-21 17:47:33.018 | Lancement de defaultServer (Open Liberty 25.0.0.5/wlp-1.0.101.cl250520250504-1901) sur Eclipse OpenJ9 VM, version 11.0.27+6 (fr_FR)
  112  2025-07-21 17:47:33.132 | [AUDIT   ] CWWKE0001I: Le serveur defaultServer a été lancé.
  113  2025-07-21 17:47:34.881 | [AUDIT   ] CWWKG0093A: Traitement de la ressource de suppression de configuration : /opt/ol/wlp/usr/servers/defaultServer/configDropins/defaults/keystore.xml
  114  2025-07-21 17:47:34.902 | [AUDIT   ] CWWKG0093A: Traitement de la ressource de suppression de configuration : /opt/ol/wlp/usr/servers/defaultServer/configDropins/defaults/open-default-port.xml
  115  2025-07-21 17:47:34.907 | [AUDIT   ] CWWKG0028A: Traitement de la ressource de configuration incluse : /opt/ol/wlp/usr/servers/defaultServer/oidc-liberty.xml
  116  2025-07-21 17:47:35.004 | [AVERTISSEMENT] TRAS0034W: Le niveau de trace all         info pour la spécification io.openliberty.security.*=all         info=enabled n'est pas valide. La spécification de trace sera ignorée.
  117  2025-07-21 17:47:39.977 | [AUDIT   ] CWWKG0102I: Des paramètres en conflit ont été détectés pour l'instance defaultKeyStore de la configuration de keyStore
  118  2025-07-21 17:47:39.977 |   La propriété password comporte des valeurs en conflit :
  119  2025-07-21 17:47:39.977 |     Valeur sécurisée définie dans file:/opt/ol/wlp/usr/servers/defaultServer/configDropins/defaults/keystore.xml.
  120  2025-07-21 17:47:39.977 |     Valeur sécurisée définie dans file:/opt/ol/wlp/usr/servers/defaultServer/server.xml.
  121  2025-07-21 17:47:39.977 |   La propriété password sera définie sur la valeur définie dans file:/opt/ol/wlp/usr/servers/defaultServer/server.xml.
  122  2025-07-21 17:47:39.977 |  2025-07-21 17:47:41.343 | [AUDIT   ] CWWKZ0058I: Recherche d'applications dans dropins.
  123  2025-07-21 17:47:50.865 | [AUDIT   ] CWWKT0016I: Application Web disponible, (default_host) : http://52918eda1be9:9060/oidcclient/
  124  2025-07-21 17:47:50.865 | [AUDIT   ] CWWKT0016I: Application Web disponible, (default_host) : http://52918eda1be9:9060/ibm/api/
  125  2025-07-21 17:47:50.888 | [AUDIT   ] CWWKT0016I: Application Web disponible, (default_host) : http://52918eda1be9:9060/jwt/
  126  2025-07-21 17:47:50.896 | [AUDIT   ] CWWKT0016I: Application Web disponible, (default_host) : http://52918eda1be9:9060/IBMJMXConnectorREST/
  127  2025-07-21 17:47:51.057 | [AUDIT   ] CWWKT0016I: Application Web disponible, (default_host) : http://52918eda1be9:9060/oauth2/
  128  2025-07-21 20:48:23.389 | [AUDIT   ] CWWKT0016I: Application Web disponible, (default_host) : http://52918eda1be9:9060/decisioncenter-api/
  129  2025-07-21 20:48:24.247 | [AVERTISSEMENT] CWNEN0070W: La classe d'annotation javax.annotation.sql.DataSourceDefinition ne sera pas reconnue car elle a été chargée à partir de l'emplacement file:/opt/ol/wlp/usr/servers/defaultServer/apps/expanded/decisioncenter-api.war/WEB-INF/lib/jakarta.annotation-api-1.3.5.jar et non à partir d'un chargeur de classe de produit.
  130  2025-07-21 20:48:24.250 | [AVERTISSEMENT] CWNEN0070W: La classe d'annotation javax.annotation.Resource ne sera pas reconnue car elle a été chargée à partir de l'emplacement file:/opt/ol/wlp/usr/servers/defaultServer/apps/expanded/decisioncenter-api.war/WEB-INF/lib/jakarta.annotation-api-1.3.5.jar et non à partir d'un chargeur de classe de produit.
  131  2025-07-21 20:48:26.759 | 
  132  2025-07-21 20:48:26.759 |  _____  ______   ____    ____     ___   ______   ____    ____
  133  2025-07-21 20:48:26.759 | |_   _||_   _ \ |_   \  /   _|  .'   `.|_   _ `.|_   \  /   _| 2025-07-21 20:48:26.759 |   | |    | |_) |  |   \/   |   /  .-.  \ | | `. \ |   \/   |
  134  2025-07-21 20:48:26.759 |   | |    |  __'.  | |\  /| |   | |   | | | |  | | | |\  /| |
  135  2025-07-21 20:48:26.759 |  _| |_  _| |__) |_| |_\/_| |_  \  `-'  /_| |_.' /_| |_\/_| |_
  136  2025-07-21 20:48:26.759 | |_____||_______/|_____||_____|  `.___.'|______.'|_____||_____|
  137  2025-07-21 20:48:26.759 |  2025-07-21 20:48:26.759 | :: Decision Center - Rest API - 8.11.1.0.1 :: built with Spring Boot (v2.6.7)
  138  2025-07-21 20:48:28.347 | [AUDIT   ] CWWKZ0022W: Application decisioncenter-api non démarrée en 30,174 secondes.
  139  2025-07-21 20:48:28.347 | [AUDIT   ] CWWKZ0022W: Application decisioncenter non démarrée en 30,173 secondes.
  140  2025-07-22 08:39:58.328 | [AUDIT   ] CWWKF0012I: Le serveur a installé les fonctions suivantes : [appSecurity-2.0, appSecurity-3.0, cdi-2.0, concurrent-1.0, distributedMap-1.0, el-3.0, federatedRegistry-1.0, jaxrs-2.1, jaxrsClient-2.1, jdbc-4.2, jndi-1.0, json-1.0, jsonp-1.1, jsp-2.3, ldapRegistry-3.0, oauth-2.0, openidConnectClient-1.0, restConnector-2.0, servlet-4.0, ssl-1.0, transportSecurity-1.0].
  141  2025-07-22 08:39:58.330 | [AUDIT   ] CWWKF0011I: Le serveur defaultServer est prêt pour une planète plus intelligente. Il a démarré en 50,965 secondes.
  142  2025-07-22 08:40:09.770 | [AVERTISSEMENT] You are asking Spring Security to ignore Ant [pattern='/**', OPTIONS]. This is not recommended -- please use permitAll via HttpSecurity#authorizeHttpRequests instead.
  143  2025-07-22 08:40:09.875 | [AVERTISSEMENT] Exception encountered during context initialization - cancelling refresh attempt: org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'decisionCenterApi' defined in class path resource [com/ibm/rules/decisioncenter/api/SwaggerConfig.class]: Bean instantiation via factory method failed; nested exception is org.springframework.beans.BeanInstantiationException: Failed to instantiate [io.swagger.v3.oas.models.OpenAPI]: Factory method 'decisionCenterApi' threw exception; nested exception is java.time.format.DateTimeParseException: Text '2021-Jan-20 10:30:00 GMT' could not be parsed at index 5
  144  2025-07-22 08:40:09.958 | [ERREUR  ] Application run failed
  145  2025-07-22 08:40:09.958 | Error creating bean with name 'decisionCenterApi' defined in class path resource [com/ibm/rules/decisioncenter/api/SwaggerConfig.class]: Bean instantiation via factory method failed; nested exception is org.springframework.beans.BeanInstantiationException: Failed to instantiate [io.swagger.v3.oas.models.OpenAPI]: Factory method 'decisionCenterApi' threw exception; nested exception is java.time.format.DateTimeParseException: Text '2021-Jan-20 10:30:00 GMT' could not be parsed at index 5
  146  2025-07-22 08:40:10.048 | [AUDIT   ] CWWKT0016I: Application Web disponible, (default_host) : http://52918eda1be9:9060/decisioncenter/
  147  2025-07-22 08:40:13.774 |  2025-07-22 08:40:13.775 |  _____  ______   ____    ____     ___   ______   ____    ____
  148  2025-07-22 08:40:13.775 | |_   _||_   _ \ |_   \  /   _|  .'   `.|_   _ `.|_   \  /   _|
  149  2025-07-22 08:40:13.775 |   | |    | |_) |  |   \/   |   /  .-.  \ | | `. \ |   \/   |
  150  2025-07-22 08:40:13.775 |   | |    |  __'.  | |\  /| |   | |   | | | |  | | | |\  /| |
  151  2025-07-22 08:40:13.775 |  _| |_  _| |__) |_| |_\/_| |_  \  `-'  /_| |_.' /_| |_\/_| |_
  152  2025-07-22 08:40:13.775 | |_____||_______/|_____||_____|  `.___.'|______.'|_____||_____|
  153  2025-07-22 08:40:13.775 |  2025-07-22 08:40:13.775 | :: Decision Center - Business Console - 8.11.1.0.1 :: built with Spring Boot (v2.6.7)
  154  2025-07-22 08:40:13.850 | [AUDIT   ] CWWKZ0012I: L'application decisioncenter-api n'a pas été démarrée.
  155  2025-07-22 08:40:13.852 | [AUDIT   ] CWWKT0017I: Application Web supprimée (default_host) : http://52918eda1be9:9060/decisioncenter-api/
  156  2025-07-22 08:40:41.801 | WARNING: An illegal reflective access operation has occurred
  157  2025-07-22 08:40:41.801 | WARNING: Illegal reflective access by org.eclipse.emf.ecore.xmi.impl.XMLHandler (file:/opt/ol/wlp/usr/servers/defaultServer/apps/expanded/decisioncenter.war/WEB-INF/lib/ecore-xmi-2.5.0.v201005211846.jar) to method com.sun.org.apache.xerces.internal.parsers.AbstractSAXParser$LocatorProxy.getEncoding()
  158  2025-07-22 08:40:41.801 | WARNING: Please consider reporting this to the maintainers of org.eclipse.emf.ecore.xmi.impl.XMLHandler
  159  2025-07-22 08:40:41.801 | WARNING: Use --illegal-access=warn to enable warnings of further illegal reflective access operations
  160  2025-07-22 08:40:41.801 | WARNING: All illegal access operations will be denied in a future release
  161  2025-07-22 08:40:45.701 | [AVERTISSEMENT] Trusting all certificates configured for Client@e9af3e0b[provider=null,keyStore=null,trustStore=null]
  162  2025-07-22 08:40:45.701 | [AVERTISSEMENT] No Client EndPointIdentificationAlgorithm configured for Client@e9af3e0b[provider=null,keyStore=null,trustStore=null]
  163  2025-07-22 08:40:45.866 | [AVERTISSEMENT] Trusting all certificates configured for Client@83aedf3b[provider=null,keyStore=null,trustStore=null]
  164  2025-07-22 08:40:45.867 | [AVERTISSEMENT] No Client EndPointIdentificationAlgorithm configured for Client@83aedf3b[provider=null,keyStore=null,trustStore=null]
  165  2025-07-22 08:40:45.891 | [AVERTISSEMENT] Not all security plugins configured!  authentication=disabled authorization=disabled.  Solr is only as secure as you make it. Consider configuring authentication/authorization before exposing Solr to users internal or external.  See https://s.apache.org/solrsecurity for more info
  166  2025-07-22 08:40:46.543 | [AVERTISSEMENT] Solr loaded a deprecated plugin/analysis class [solr.WordDelimiterFilterFactory]. Please consult documentation how to replace it accordingly.
  167  2025-07-22 08:40:46.570 | [AVERTISSEMENT] Solr loaded a deprecated plugin/analysis class [solr.TrieIntField]. Please consult documentation how to replace it accordingly.
  168  2025-07-22 08:40:46.572 | [AVERTISSEMENT] Solr loaded a deprecated plugin/analysis class [solr.TrieFloatField]. Please consult documentation how to replace it accordingly.
  169  2025-07-22 08:40:46.575 | [AVERTISSEMENT] Solr loaded a deprecated plugin/analysis class [solr.TrieLongField]. Please consult documentation how to replace it accordingly.
  170  2025-07-22 08:40:46.578 | [AVERTISSEMENT] Solr loaded a deprecated plugin/analysis class [solr.TrieDoubleField]. Please consult documentation how to replace it accordingly.
  171  2025-07-22 08:40:46.580 | [AVERTISSEMENT] Solr loaded a deprecated plugin/analysis class [solr.TrieDateField]. Please consult documentation how to replace it accordingly.
  172  2025-07-22 08:40:46.583 | [AVERTISSEMENT] Solr loaded a deprecated plugin/analysis class [solr.SynonymFilterFactory]. Please consult documentation how to replace it accordingly.
  173  2025-07-22 08:40:50.705 | [AUDIT   ] CWWKZ0001I: Application decisioncenter démarrée en 84,586 secondes.
  174  2025-07-22 10:56:34.494 | [AVERTISSEMENT] {"date":"22 juil. 2025 \u00e0 08:56:34","request":{"headers":{"Accept":"text\/html,application\/xhtml+xml,application\/xml;q=0.9,image\/avif,image\/webp,image\/apng,*\/*;q=0.8,application\/signed-exchange;v=b3;q=0.7","User-Agent":"Mozilla\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\/537.36 (KHTML, like Gecko) Chrome\/138.0.0.0 Safari\/537.36","Sec-Fetch-Site":"cross-site","Sec-Fetch-Dest":"document","Accept-Encoding":"gzip, deflate, br, zstd","priority":"u=0, i","Sec-Fetch-Mode":"navigate","sec-ch-ua":"\"Not)A;Brand\";v=\"8\", \"Chromium\";v=\"138\", \"Google Chrome\";v=\"138\"","sec-ch-ua-mobile":"?0","Cache-Control":"max-age=0","Upgrade-Insecure-Requests":"1","sec-ch-ua-platform":"\"Windows\"","Sec-Fetch-User":"?1","Accept-Language":"fr-FR,fr;q=0.9","Content-Length":"0"},"method":"GET","URL":"https:\/\/localhost:9443\/decisioncenter"},"context":{"product":{"component":"ODM Decision Center","product":{"iFixVersions":"8.11.1.0.1","patchLevel":"1-20221118-180939 COMMERCIAL","version":"8.11.1.0","buildNumber":"8111020221119041258"},"properties":{"java.vendor":"IBM Corporation","java.version":"11.0.27","os.arch":"amd64","os.name":"Linux","os.version":"5.15.153.1-microsoft-standard-WSL2"},"serverProvider":"IBM WebSphere Liberty\/25.0.0.5","network":{"hostname":"52918eda1be9","IPAddress":"172.18.0.11"}},"datasource":{"schemaVersion":"JRules 8.11.1","driver":"PostgreSQL 15.13 (Debian 15.13-1.pgdg120+1)","isolationLevel":"TRANSACTION_READ_COMMITTED","datasourceName":"jdbc\/ilogDataSource"},"message":"Database referenced by JDNI Name 'jdbc\/ilogDataSource' not initialized"},"logId":"63f045ba-8a3e-4e71-afcb-37c99e45bd90","message":"Une erreur s'est produite lors de la tentative d'acc\u00e8s \u00e0 la source de donn\u00e9es 'jdbc\/ilogDataSource' : Non initialis\u00e9. V\u00e9rifiez que la source de donn\u00e9es existe sur le serveur d'applications ou contactez votre administrateur.","timestamp":1753174594293}
  175  2025-07-22 10:56:36.666 | [ERREUR  ] Cannot forward to error page for request [/js/dist//dojo/resources/dojo.css] as the response has already been committed. As a result, the response may have the wrong status code. If your application is running on WebSphere Application Server you may be able to resolve this problem by setting com.ibm.ws.webcontainer.invokeFlushAfterService to false
  176  2025-07-22 10:56:36.723 | [ERREUR  ] Cannot forward to error page for request [/js/dist//gridx/resources/claro/Gridx.css] as the response has already been committed. As a result, the response may have the wrong status code. If your application is running on WebSphere Application Server you may be able to resolve this problem by setting com.ibm.ws.webcontainer.invokeFlushAfterService to false
  177  2025-07-22 10:56:36.781 | [ERREUR  ] Cannot forward to error page for request [/js/dist//decisioncenter/decisioncenter.js] as the response has already been committed. As a result, the response may have the wrong status code. If your application is running on WebSphere Application Server you may be able to resolve this problem by setting com.ibm.ws.webcontainer.invokeFlushAfterService to false
  178  2025-07-22 10:56:36.842 | [ERREUR  ] Cannot forward to error page for request [/js/dist//decisioncenter/rave.js] as the response has already been committed. As a result, the response may have the wrong status code. If your application is running on WebSphere Application Server you may be able to resolve this problem by setting com.ibm.ws.webcontainer.invokeFlushAfterService to false
  179  2025-07-22 10:56:36.847 | [ERREUR  ] Cannot forward to error page for request [/js/dist//dijit/themes/claro/claro.css] as the response has already been committed. As a result, the response may have the wrong status code. If your application is running on WebSphere Application Server you may be able to resolve this problem by setting com.ibm.ws.webcontainer.invokeFlushAfterService to false
  180  2025-07-22 10:56:36.848 | [ERREUR  ] Cannot forward to error page for request [/js/dist//dojox/widget/ColorPicker/ColorPicker.css] as the response has already been committed. As a result, the response may have the wrong status code. If your application is running on WebSphere Application Server you may be able to resolve this problem by setting com.ibm.ws.webcontainer.invokeFlushAfterService to false
  181  2025-07-22 10:56:36.855 | [ERREUR  ] Cannot forward to error page for request [/js/dist//dojo/dojo.js] as the response has already been committed. As a result, the response may have the wrong status code. If your application is running on WebSphere Application Server you may be able to resolve this problem by setting com.ibm.ws.webcontainer.invokeFlushAfterService to false
  182  docker compose build --no-cache decisioncenter
  183  docker compose up -d decisioncenter
  184  java -version
  185  history
  186  notepad ~/.bash_history
  187  history -a     # Appelle immédiatement l’écriture des commandes de la session dans ~/.bash_history
  188  TOKEN=$(kubectl -n ibm-licensing get secret ibm-licensing-token -o jsonpath='{.data.token}' | base64 -d)
  189  # Doit renvoyer des en-têtes HTTP/1.1 (200 ou 401 selon token)
  190  curl -i --http1.1 --max-time 10 "http://127.0.0.1:18100/status?token=$TOKEN"
  191  # Terminal C (nouvelle fenêtre)
  192  kubectl -n ibm-licensing port-forward deploy/ibm-licensing-service-instance 18101:8081
  193  curl -i --http1.1 --max-time 10 "http://127.0.0.1:18101/metrics" | head -n1
  194  cd /c/workspaces/odm-cloudnative-2025-2029/odm-dev/
  195  wsl --version
  196  docker version
  197  docker info --format "CPUs: {{.NCPU}}  MemTotal: {{.MemTotal}}"
  198  docker version
  199  docker info --format "CPUs: {{.NCPU}}  MemTotal: {{.MemTotal}}"
  200  kind create cluster --name odm-dev --config kind-config.yaml
  201  kubectl cluster-info
  202  history
  203  histroy | delete
  204  history | delete
  205  kind delete cluster --name odm-dev
  206  kind create cluster --name odm-dev --config kind-config.yaml
  207  kubectl cluster-info
  208  kubectl cluster-info --context kind-odm-dev
  209  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
  210  kubectl -n ingress-nginx rollout status deploy/ingress-nginx-controller
  211  kubectl -n ingress-nginx get pods -o wide
  212  kubectl -n ingress-nginx logs deploy/ingress-nginx-controller --tail=80
  213  curl -I --noproxy "*" http://127.0.0.1/
  214  kubectl create ns odm-dev
  215  helm repo add ibm-helm-repo https://raw.githubusercontent.com/IBM/charts/master/repo/stable/
  216  helm repo update
  217  helm install odm-dev ibm-helm-repo/ibm-odm-dev -n odm-dev   --set-string license=accept   --set-string usersPassword='MonP@ssw0rdSolide!'   --set service.type=ClusterIP   --set image.repository=icr.io/cpopen/odm-k8s   --set internalDatabase.persistence.enabled=true   --set internalDatabase.persistence.useDynamicProvisioning=true   --set internalDatabase.persistence.storageClassName=standard
  218  kubectl -n odm-dev get pods,svc
  219  kubectl -n odm-dev get endpoints
  220  kubectl -n odm-dev logs deploy/odm-dev-ibm-odm-dev --tail=50
  221  kubectl apply -f odm-ingress.yaml
  222  kubectl -n odm-dev get ingress odm-dev-ingress -o wide
  223  kubectl -n odm-dev describe ingress odm-dev-ingress
  224  kubectl -n odm-dev describe ingress odm-dev-ingress
  225  curl -I --resolve odm.local:80:127.0.0.1 http://odm.local/decisioncenter
  226  curl -I --resolve odm.local:80:127.0.0.1 http://odm.local/res
  227  curl -I --resolve odm.local:80:127.0.0.1 http://odm.local/DecisionService
  228  curl -I --resolve odm.local:80:127.0.0.1 http://odm.local/DecisionRunner
  229  kubectl create ns keycloak
  230  helm repo add bitnami https://charts.bitnami.com/bitnami
  231  helm repo update
  232  helm install keycloak bitnami/keycloak -n keycloak   --set auth.adminUser=admin   --set auth.adminPassword='AdminP@ss-ChangeMe'   --set proxy=edge   --set httpRelativePaths=true   --set service.type=ClusterIP   --set postgresql.enabled=true   --set ingress.enabled=true   --set ingress.hostname=keycloak.local   --set ingress.ingressClassName=nginx
  233  kubectl -n keycloak get sts,pods,svc,ingress
  234  curl -I --resolve keycloak.local:80:127.0.0.1 http://keycloak.local/
  235  kubectl -n odm-dev get pods
  236  kubectl -n odm-dev get ns
  237  pwd
  238  docker build -t apache-oidc:latest docker/apache-oidc
  239  kind load docker-image apache-oidc:latest --name odm-dev
  240  docker tag apache-oidc:latest apache-oidc:v0.1.0
  241  kind load docker-image apache-oidc:v0.1.0 --name odm-dev
  242  docker exec -it odm-dev-control-plane crictl images | grep apache-oidc
  243  IP=$(kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.spec.clusterIP}')
  244  KC_SECRET='<TON_CLIENT_SECRET_KEYCLOAK>'
  245  sed -e "s|\${INGRESS_IP}|$IP|g"     -e "s|<COLLE_ICI_LE_CLIENT_SECRET_KEYCLOAK>|$KC_SECRET|g"     k8s/apache-oidc.yaml | kubectl apply -f -
  246  REAL_SECRET='NUxhDaqhzevIqkUV8efMMV5fPwMDLVT1'
  247  sed -e "s|\${INGRESS_IP}|$IP|g"     -e "s|<COLLE_ICI_LE_CLIENT_SECRET_KEYCLOAK>|$KC_SECRET|g"     k8s/apache-oidc.yaml | kubectl apply -f -
  248  echo IP=$(kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.spec.clusterIP}')
  249  kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.spec.clusterIP}'
  250  kubectl apply -f k8s/apache-oidc.yaml
  251  kubectl -n odm-dev rollout status deploy/odm-oidc-proxy
  252  curl -I --resolve odm.local:80:127.0.0.1 http://odm.local/decisioncenter
  253  kubectl get ingress -A -o wide
  254  kubectl -n odm-dev delete ingress odm-dev-ingress
  255  kubectl get ingress -A -o wide
  256  url -I --resolve odm.local:80:127.0.0.1 http://odm.local/decisioncenter
  257  curl -I --resolve odm.local:80:127.0.0.1 http://odm.local/decisioncenter
  258  # Le trafic passe bien par ton proxy ?
  259  kubectl -n odm-dev logs deploy/odm-oidc-proxy --tail=50
  260  # L’Ingress actif pointe bien vers le service du proxy :
  261  kubectl -n odm-dev describe ingress odm-oidc-ingress | sed -n '/Rules/,$p'
  262  # Le service du proxy a des endpoints ?
  263  kubectl -n odm-dev get endpoints odm-oidc-proxy
  264  kubectl -n odm-dev logs deploy/odm-oidc-proxy --tail=200
  265  kubectl -n odm-dev get po,svc,endpoints | grep odm-oidc-proxy
  266  docker build -t apache-oidc:v0.1.1 docker/apache-oidc
  267  kind load docker-image apache-oidc:v0.1.1 --name odm-dev
  268  kubectl -n odm-dev set image deploy/odm-oidc-proxy httpd=apache-oidc:v0.1.1
  269  kubectl -n odm-dev rollout status deploy/odm-oidc-proxy
  270  curl -I --resolve odm.local:80:127.0.0.1 http://odm.local/decisioncenter
  271  # attendu : 302 → http://keycloak.local/realms/odm-poc/...
  272  # Keycloak reachable depuis le pod ?
  273  kubectl -n odm-dev exec deploy/odm-oidc-proxy -- curl -sI http://keycloak.local/.well-known/openid-configuration | head -n1
  274  # Logs Apache (cherche response_type / invalid / error)
  275  kubectl -n odm-dev logs deploy/odm-oidc-proxy --tail=200 | egrep -i 'response_type|invalid|error|callback'
  276  # (option) activer debug mod_auth_openidc
  277  kubectl -n odm-dev exec deploy/odm-oidc-proxy -- bash -lc  'printf "\nLogLevel auth_openidc:debug\n" >> /etc/apache2/apache2.conf; apachectl -k graceful'
  278  docker build -t apache-oidc:v0.1.1 docker/apache-oidc
  279  kind load docker-image apache-oidc:v0.1.1 --name odm-dev
  280  kubectl -n odm-dev set image deploy/odm-oidc-proxy httpd=apache-oidc:v0.1.1
  281  kubectl -n odm-dev rollout status deploy/odm-oidc-proxy
  282  # 302 vers Keycloak attendu
  283  curl -I --resolve odm.local:80:127.0.0.1 http://odm.local/decisioncenter
  284  # Logs Apache (callback/token)
  285  kubectl -n odm-dev logs deploy/odm-oidc-proxy --tail=200 | egrep -i 'callback|code|token|error'
  286  kubectl -n odm-dev logs deploy/odm-oidc-proxy --tail=200 | egrep -i 'callback|code|token|error'
  287  curl -I http://odm.local/decisioncenter
  288  kubectl get ns ibm-licensing || kubectl create ns ibm-licensing
  289  kubectl -n ibm-licensing get deploy,svc,ingress
  290  kubectl get crd | grep -i ibmlicensing || echo "CRD absente"
  291  kubectl apply -f https://github.com/operator-framework/operator-lifecycle-manager/releases/latest/download/install.yaml
  292  kubectl -n olm rollout status deploy/olm-operator
  293  kubectl -n olm rollout status deploy/catalog-operator
  294  kubectl -n olm get pods
  295  curl -L -o olm-crds.yaml https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.32.0/crds.yaml
  296  curl -L -o olm.yaml     https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.32.0/olm.yaml
  297  kubectl apply -f olm-crds.yaml
  298  kubectl apply -f olm.yaml
  299  ls
  300  # 1) Créer/mettre à jour les CRD en "server-side apply"
  301  kubectl apply --server-side -f olm-crds.yaml
  302  # 2) Vérifier que la CRD des CSV est là
  303  kubectl get crd clusterserviceversions.operators.coreos.com
  304  # 3) Appliquer le reste d’OLM
  305  kubectl apply -f olm.yaml
  306  # 4) Vérifier que tout tourne
  307  kubectl -n olm get pods
  308  kubectl -n olm rollout status deploy/olm-operator
  309  kubectl -n olm rollout status deploy/catalog-operator
  310  kubectl -n olm get catalogsources
  311  # Vois-tu un package "ibm-licensing-operator" ?
  312  kubectl get packagemanifests | grep -i licensing || true
  313  kubectl apply -f ibm-operator-catalog.yaml
  314  kubectl -n olm get catalogsources
  315  kubectl get packagemanifests | grep -i licensing
  316  # Le packageserver doit être Ready (sinon la liste des packages sera vide)
  317  kubectl -n olm get deploy packageserver
  318  kubectl -n olm rollout status deploy/packageserver
  319  # Affiche tous les packages liés au licensing
  320  kubectl get packagemanifests | grep -i licensing
  321  # (si rien n’apparaît, re-vérifie le packageserver ci-dessus)
  322  # Voir les channels publiés par le package
  323  kubectl get packagemanifest ibm-licensing-operator -o jsonpath='{range .status.channels[*]}{.name}{"\n"}{end}'
  324  # Savoir quel est le channel par défaut
  325  kubectl get packagemanifest ibm-licensing-operator -o jsonpath='{.status.defaultChannel}{"\n"}'
  326  kubectl get packagemanifest ibm-licensing-operator-app -o jsonpath='{.status.defaultChannel}{"\n"}'
  327  kubectl get packagemanifest ibm-licensing-operator-app -o jsonpath='{range .status.channels[*]}{.name}{"\n"}{end}'
  328  kubectl get packagemanifest ibm-licensing-operator-app -o jsonpath='{.status.catalogSource}{" / "}{.status.catalogSourceNamespace}{"\n"}'
  329  # (tu dois voir "ibm-operator-catalog / olm")
  330  kubectl apply -f ibm-licensing-operator.yaml
  331  kubectl -n ibm-licensing get sub,csv
  332  # (tu peux suivre en live)
  333  kubectl -n ibm-licensing get csv -w
  334  TOKEN=$(kubectl -n ibm-licensing get secret ibm-licensing-token -o jsonpath='{.data.token}' | base64 -d)
  335  curl -I --resolve licensing.local:80:127.0.0.1   "http://licensing.local/ibm-licensing-service-instance/status?token=$TOKEN"
  336  TOKEN=$(kubectl -n ibm-licensing get secret ibm-licensing-token -o jsonpath='{.data.token}' | base64 -d)
  337  curl -I --resolve licensing.local:80:127.0.0.1   "http://licensing.local/ibm-licensing-service-instance/status?token=$TOKEN"
  338  kubectl -n ibm-licensing get csv -w
  339  kubectl -n ibm-licensing get endpoints ibm-licensing-service-instance
  340  cd /c/workspaces/odm-cloudnative-2025-2029/odm-dev/
  341  kubectl apply -f ibm-licensing-ingress.yaml
  342  kubectl -n ibm-licensing get ingress ibm-licensing-service-instance -o wide
  343  # Assure-toi que hosts Windows contient: 127.0.0.1 licensing.local
  344  TOKEN=$(kubectl -n ibm-licensing get secret ibm-licensing-token -o jsonpath='{.data.token}' | base64 -d)
  345  curl -v --http1.1 --max-time 10 --resolve licensing.local:80:127.0.0.1   "http://licensing.local/ibm-licensing-service-instance/status?token=$TOKEN"
  346  # Lance le PF en *autre terminal* (laisse-le tourner)
  347  kubectl -n ibm-licensing port-forward svc/ibm-licensing-service-instance 18080:8080
  348  # Dans ton terminal courant :
  349  curl -v --http1.1 --max-time 10 "http://127.0.0.1:18080/status?token=$TOKEN"
  350  kubectl -n ibm-licensing get ingress ibm-licensing-service-instance -o yaml | grep rewrite-target -n
  351  # => doit afficher: nginx.ingress.kubernetes.io/rewrite-target: "/$2"
  352  # tue tous les port-forwards kubectl en cours (Windows)
  353  taskkill /IM kubectl.exe /F
  354  # (option) vérifie qu'aucun process n'écoute sur 18100/18101
  355  netstat -ano | grep -E ":18100|:18101" || true
  356  # (dans Git Bash)
  357  netstat -ano | grep -E ":18100|:18101" || true
  358  # ou en PowerShell
  359  powershell.exe -NoProfile -Command "Get-NetTCPConnection -LocalPort 18100,18101 -State Listen"
  360  netstat -ano | grep -E ":18100|:18101" || true
  361  kubectl -n ibm-licensing port-forward svc/ibm-licensing-service-instance 18100:8080
  362  cd /c/workspaces/
  363  ls
  364  mkdir gitops
  365  cd gitops/
  366  nano bootstrap.sh
  367  chmod +x bootstrap.sh
  368  ./bootstrap.sh 
  369  echo "$GH_TOKEN" | gh auth login --with-token
  370  gh repo create zdmooc/argocd-cert-pack --private --source=. --remote=origin --push
  371  ls
  372  chmod +x bootstrapApi.sh
  373  ./bootstrapApi.sh
  374  ./bootstrapApi.sh
  375  chmod +x check_kind_argocd.sh
  376  ./check_kind_argocd.sh
  377  chmod +x install_argocd_min.sh check_kind_argocd_v2.sh
  378  # 1) si Argo CD absent:
  379  ./install_argocd_min.sh
  380  # 2) audit + URL + mot de passe:
  381  ./check_kind_argocd_v2.sh
  382  cat <<'YAML' | kubectl apply -f -
  383  apiVersion: networking.k8s.io/v1
  384  kind: Ingress
  385  metadata:
  386    name: argocd-server
  387    namespace: argocd
  388    annotations:
  389      kubernetes.io/ingress.class: nginx
  390  spec:
  391    rules:
  392    - host: argocd.local
  393      http:
  394        paths:
  395        - path: /
  396          pathType: Prefix
  397          backend:
  398            service:
  399              name: argocd-server
  400              port:
  401                number: 80
  402  YAML
  403  IP=$(kubectl get node -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
  404  echo "$IP  argocd.local" | sudo tee -a /etc/hosts
  405  # UI: http://argocd.local
  406  echo $IP
  407  kubectl -n argocd get secret argocd-initial-admin-secret   -o jsonpath='{.data.password}' | base64 -d; echo
  408  argocd login argocd.local --username admin --password 'xLxn0NgUeDpZ8uPB' --insecure
  409  # 1) Génère le script de complétion
  410  mkdir -p ~/.bash_completion.d
  411  argocd completion bash > ~/.bash_completion.d/argocd
  412  # 2) Active à chaque session
  413  grep -q 'bash_completion.d/argocd' ~/.bashrc || cat >> ~/.bashrc <<'EOF'
  414  # Argo CD CLI completion
  415  if [ -f ~/.bash_completion.d/argocd ]; then
  416    source ~/.bash_completion.d/argocd
  417  fi
  418  EOF
  419  # 3) Recharge
  420  source ~/.bashrc
  421  kubectl -n argocd get secret argocd-initial-admin-secret `
  422    -o jsonpath="{.data.password}" | base64 -d; echo
  423  mkdir -p ~/.bash_completion.d
  424  argocd completion bash > ~/.bash_completion.d/argocd
  425  grep -q 'bash_completion.d/argocd' ~/.bashrc || cat >> ~/.bashrc <<'EOF'
  426  # Argo CD CLI completion
  427  [ -f ~/.bash_completion.d/argocd ] && . ~/.bash_completion.d/argocd
  428  EOF
  429  source ~/.bashrc
  430  # test
  431  argocd <TAB><TAB>
  432  cat ~/.bash_completion.d
  433  ls ~/.bash_completion.d
  434  cat ~/.bash_completion.d/argocd
  435  source ~/.bashrc
  436  argocd login argocd.local --username admin --password 'xLxn0NgUeDpZ8uPB' --insecure
  437  ipconfig /flushdns
  438  kubectl -n ingress-nginx get svc ingress-nginx-controller -o wide
  439  # TYPE=NodePort ok. Test:
  440  curl -sI http://argocd.local | head -n 3
  441  argocd login argocd.local --username admin --password 'xLxn0NgUeDpZ8uPB' --insecure
  442  argocd login argocd.local --username admin --password 'xLxn0NgUeDpZ8uPB' --insecure
  443  argocd login argocd.local --username admin --password 'xLxn0NgUeDpZ8uPB' --grpc-web --insecure
  444  # kind_audit.sh
  445  #!/usr/bin/env bash
  446  set -e
  447  echo "== CONTEXT =="; kubectl config current-context
  448  echo "== NODES =="; kubectl get nodes -o wide
  449  echo "== NAMESPACES =="; kubectl get ns --no-headers | awk '{print $1}' | sort
  450  echo "== ARGOCD OBJECTS =="; kubectl -n argocd get all
  451  echo "== INGRESS-NGINX =="; kubectl -n ingress-nginx get all
  452  echo "== CRDs ARGOCD =="; kubectl get crd | grep argoproj.io || echo "none"
  453  echo "== APPS ARGOCD (si CLI dispo) =="; if command -v argocd >/dev/null; then   echo "Utilise: argocd app list  (après login 127.0.0.1:8080)"; else echo "argocd CLI non présent dans PATH"; fi
  454  kubectl -n ingress-nginx get deploy ingress-nginx-controller -o yaml | less
  455  kubectl -n ingress-nginx get deploy ingress-nginx-controller -o yaml | less
  456  kubectl -n ingress-nginx get svc ingress-nginx-controller -o yaml
  457  kubectl -n ingress-nginx get svc ingress-nginx-controller-admission -o yaml
  458  kubectl -n ingress-nginx get cm ingress-nginx-controller -o yaml
  459  kubectl -n ingress-nginx get pods
  460  kubectl -n ingress-nginx logs deploy/ingress-nginx-controller
  461  kubectl -n ingress-nginx get pods
  462  kubectl get ingress -A
  463  kubectl get ingress -A -o jsonpath='{range .items[*]}{.metadata.namespace}{";"}{.metadata.name}{";"}{range .spec.rules[*]}{.host}{";"}{range .http.paths[*]}{.path}{";"}{.backend.service.name}{":"}{.backend.service.port.number}{"\n"}{end}{end}{end}'
  464  kubectl get ingress -A -o jsonpath='{range .items[*].spec.rules[*].http.paths[*]}{.path}{"\n"}{end}' | wc -l
  465  kubectl config get-contexts
  466  kubectl --context=default/api-crc-testing:6443/kubeadmin cluster-info
  467  oc login https://api.crc.testing:6443 -u kubeadmin -p wyHyD-uKD4m-cJqWU-KhLqw
  468  # 1. Ouvre un nouveau Git Bash (important)
  469  # 2. Ajoute le chemin (avec échappement des espaces)
  470  echo 'export PATH="/c/Users/HP\ 17\ G3\ Win\ 11\ 23H2/.crc/bin/oc:$PATH"' >> ~/.bashrc
  471  source ~/.bashrc
  472  # 3. Vérifie
  473  which oc || type -a oc
  474  oc version
  475  mkdir -p ~/bin
  476  ln -sf "/c/Users/HP 17 G3 Win 11 23H2/.crc/bin/oc/oc.exe" ~/bin/oc
  477  echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
  478  source ~/.bashrc
  479  oc version
  480  oc login https://api.crc.testing:6443 -u kubeadmin -p wyHyD-uKD4m-cJqWU-KhLqw
  481  oc whoami
  482  oc get nodes
  483  oc get pods -A
  484  cd /c/workspaces/
  485  cd /c/workspaces/gitops/argocd-cert-pack/
  486  ls
  487  crc setup
  488  crc daemon
  489  crc start
  490  oc login https://api.crc.testing:6443 -u kubeadmin -p wyHyD-uKD4m-cJqWU-KhLqw
  491  oc get nodes
  492  oc get pods -A
  493  oc login https://api.crc.testing:6443 -u kubeadmin -p wyHyD-uKD4m-cJqWU-KhLqw
  494  oc whoami
  495  oc get nodes
  496  oc get pods -A
  497  oc login https://api.crc.testing:6443 -u kubeadmin -p 'wyHyD-uKD4m-cJqWU-KhLqw'
  498  oc whoami
  499  oc get nodes --show-labels
  500  oc get pods -n openshift-kube-apiserver
  501  oc get pods -n openshift-etcd
  502  oc get pods -n openshift-kube-scheduler
  503  # Plans de contrôle
  504  oc get pods -n openshift-kube-apiserver
  505  oc get pods -n openshift-etcd
  506  oc get pods -n openshift-kube-scheduler
  507  oc get pods -n openshift-controller-manager
  508  # Réseau et entrée
  509  oc get pods -n openshift-ovn-kubernetes
  510  oc get pods -n openshift-ingress
  511  oc get routes -A
  512  # Registry / OLM
  513  oc get pods -n openshift-image-registry
  514  oc get pods -n openshift-operator-lifecycle-manager
  515  # Tes workloads
  516  oc get projects
  517  oc get pods -n <ton-namespace>
  518  oc get projects
  519  # Plans de contrôle
  520  oc get pods -n openshift-kube-apiserver
  521  oc get pods -n openshift-etcd
  522  oc get pods -n openshift-kube-scheduler
  523  oc get pods -n openshift-controller-manager
  524  # Réseau et entrée
  525  oc get pods -n openshift-ovn-kubernetes
  526  oc get pods -n openshift-ingress
  527  oc get routes -A
  528  # Registry / OLM
  529  oc get pods -n openshift-image-registry
  530  oc get pods -n openshift-operator-lifecycle-manager
  531  # Tes workloads
  532  NS=odm-dev   # adapte si besoin
  533  oc get projects
  534  oc get pods -n "$NS"
  535  history
  536  oc get nodes
  537  oc get pods
  538  oc get pods -A
  539  oc get routes -A
  540  oc get projects
  541  oc registry info
  542  oc get routes -A
  543  oc get pods -A
  544  cd /c/workspaces/gitops/
  545  ls -altr
  546  bash init-openshift-cert.sh
  547  sed -i 's/\r$//' init-openshift-cert.sh
  548  bash init-openshift-cert.sh
  549  bash init-openshift-cert.sh
  550  ls -latr
  551  ls
  552  ls -latr
  553* 
  554  chmod +x openshift-ex288.sh
  555  ls -latr
  556  chmod +x openshift-ex288.sh
  557  bash openshift-ex288.sh
  558  echo "$BASH_VERSION"   # doit afficher une version
  559  uname -s               # MINGW64 ou Linux attendu
  560  gh
  561  cd cd /c/workspaces/gitops/openshift-ex288
  562  cd /c/workspaces/gitops/openshift-ex288
  563  pwd
  564  gh repo create zdmooc/openshift-ex288 --private --source=. --remote=origin --push
  565  gh auth login
  566  gh auth status
  567  cd /c/workspaces/gitops/openshift-ex288
  568  gh repo create zdmooc/openshift-ex288 --private --source=. --remote=origin --push
  569  cd /c/workspaces/gitops/openshift-ex288
  570  sed -i 's#REPLACE_WITH_YOUR_REPO_URL#https://github.com/zdmooc/openshift-ex288.git#g' manifests/bc-is.yaml
  571  git add manifests/bc-is.yaml
  572  git commit -m "set BuildConfig repo URL"
  573  git push
  574  ls
  575  ls -latr
  576  l
  577  history >> commandehistory.sh
