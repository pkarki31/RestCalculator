FROM openjdk:8u131-jdk-alpine

ARG SPRING_PROFILES_ACTIVE
ARG ENV_PROFILES_ACTIVE
ARG APPLICATIONINSIGHTS_CONNECTION_STRING

EXPOSE 8080
EXPOSE 8081

#Requires for splunk data
RUN mkdir -p /logs
RUN chmod -R 777 /logs
COPY target/demo-0.0.1-SNAPSHOT.jar /opt/optum/web.jar
COPY jmx-config.yaml /opt/optum/jmx-config.yaml

RUN apk add --no-cache curl
RUN curl -o /opt/optum/jmx_agent.jar https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.3.0/jmx_prometheus_javaagent-0.3.0.jar

ENV SPRING_PROFILES_ACTIVE=${SPRING_PROFILES_ACTIVE}
#ENV ENV_PROFILES_ACTIVE=${ENV_PROFILES_ACTIVE}
ENV ENV_PROFILES_ACTIVE=${SPRING_PROFILES_ACTIVE}

# For Elastic APM Agent install Information see the following:	
# https://www.elastic.co/guide/en/apm/agent/java/current/setup-javaagent.html	
# https://www.elastic.co/guide/en/apm/agent/java/current/setup-attach-cli.html	
USER root	
RUN mkdir -p /opt/elastic/apm	
RUN chmod -R 755 /opt/elastic/apm	
RUN curl -L https://repo1.uhc.com/artifactory/UHG-Thirdparty-Snapshots/com/elastic/apm/agents/java/current/elastic-apm-agent.jar -o /opt/elastic/apm/elastic-apm-agent.jar	

# Required to be passed to JVM - see bottom CMD statement	
ENV ES_AGENT=" -javaagent:/opt/elastic/apm/elastic-apm-agent.jar"	

#All These Enviornment Variables can be overridden via the Deployment Environment Variables	
#https://www.elastic.co/guide/en/apm/agent/java/current/configuration.html	
#https://www.elastic.co/guide/en/apm/agent/java/current/config-core.html	
#	
# Required Environment Variables pulled by elastic agent from environment when agent starts	
#	
# ENV ELASTIC_APM_SERVICE_NAME="<ASK_NAME-ASK_ID>"	
# ENV ELASTIC_APM_SERVER_URLS="<https://Elastic-APM-Server-Data-Center>"	
#    Where Elastic-APM-Server-Data-Center is:	
#       Core-ELR: https://eapm-nonprod-elr.uhc.com	
#       Core-CTC: https://eapm-nonprod-ctc.uhc.com	
#        DMZ-ELR: https://eapm-nonprod-elr-dmz.optum.com	
#        DMZ-CTC: https://eapm-nonprod-ctc-dmz.optum.com	
#	
# Encouraged for performance in monitoring resouces, narrows scope of what is monitored	
# ELASTIC_APM_APPLICATION_PACKAGES="optum.apm,optum.dan"	
#	
# Nice to Have	
# ELASTIC_APM_ACTIVE="true|false"	
# ELASTIC_APM_ENVIRONMENT="Development|Test|Stage|Prod"	

# Required - Reminder - can be overridden via pod environment variables	
ENV ELASTIC_APM_SERVICE_NAME="FIELD-TOOL-MODERNIZATION_UHGWM110-025756"	
ENV ELASTIC_APM_SERVER_URLS="https://eapm-nonprod-elr-dmz.optum.com"	
ENV ELASTIC_APM_VERIFY_SERVER_CERT="false"	

#Optional but Recommended - can be overridden via pod environment variables	
ENV ELASTIC_APM_ENVIRONMENT=${SPRING_PROFILES_ACTIVE}
ENV ELASTIC_APM_ACTIVE="true"

# This is preferred but APM will not work out of the box, without setting deployment configs	
#CMD ["/bin/sh", "-c","java $ES_AGENT -Delastic.apm.service_name=${ES_APM_SERVICE_NAME} -jar /opt/optum/app.jar"]	

#*************************************************************************************************************************************************************************************************
# For Appinsight java jar Agent install Information see the following:
USER root	
RUN mkdir -p /opt/appinsight/agent	
RUN chmod -R 755 /opt/appinsight/agent	
RUN curl -L https://github.com/microsoft/ApplicationInsights-Java/releases/download/3.0.0-PREVIEW.7/applicationinsights-agent-3.0.0-PREVIEW.7.jar -o /opt/appinsight/agent/applicationinsights-agent-3.0.0-PREVIEW.7.jar	

# Required to be passed to JVM - see bottom CMD statement	
ENV APPINSIGHT_AGENT="-javaagent:/opt/appinsight/agent/applicationinsights-agent-3.0.0-PREVIEW.7.jar"
ENV APPLICATIONINSIGHTS_CONNECTION_STRING=${APPLICATIONINSIGHTS_CONNECTION_STRING}
ENV APPLICATIONINSIGHTS_ROLE_NAME="FTM-ANNOUNCEMENT"

COPY src/main/resources/ApplicationInsights.json /opt/appinsight/agent/ApplicationInsights.json

USER 1001
#CMD ["java","-javaagent:/opt/optum/jmx_agent.jar=8081:/opt/optum/jmx-config.yaml", "-XX:+UnlockExperimentalVMOptions", "-XX:+UseCGroupMemoryLimitForHeap", "-XX:MaxRAMFraction=1", "-XshowSettings:vm", "-jar", "/opt/optum/web.jar"]
CMD ["java","-Dspring.profiles.active=${SPRING_PROFILES_ACTIVE}","-javaagent:/opt/optum/jmx_agent.jar=8081:/opt/optum/jmx-config.yaml", "-XX:+UnlockExperimentalVMOptions", "-XX:+UseCGroupMemoryLimitForHeap","-XX:MaxRAMFraction=1", "-XshowSettings:vm","-javaagent:/opt/appinsight/agent/applicationinsights-agent-3.0.0-PREVIEW.7.jar","-jar", "/opt/optum/web.jar"]