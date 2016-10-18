# ibcp全模块镜像
# 基于tomcat镜像的ibcp镜像
# OS：debian:jessie
FROM tomcat:8.5.5-jre8

# 发布服务地址
ENV PACKAGE_URL
# 发布服务用户名
ENV PACKAGE_USER
# 发布服务用户密码
ENV PACKAGE_PASSWORD
# 版本路径
ENV PACKAGE_VERSION

# 作者
MAINTAINER Niuren.Zhu "niuren.zhu@outlook.com"

# 补充变量值
RUN if [ "${PACKAGE_URL}" = "" ];then ${PACKAGE_URL}=http://ibas:8866/ibcp/; fi; \
RUN if [ "${PACKAGE_USER}" = "" ];then ${PACKAGE_USER}=avatech/\ibcp_publisher; fi; \
RUN if [ "${PACKAGE_PASSWORD}" = "" ];then ${PACKAGE_PASSWORD}=1q2w#E\$R; fi; \
RUN if [ "${PACKAGE_VERSION}" = "" ];then ${PACKAGE_VERSION}=latest/; fi; \

# 部署ibcp程序
RUN set -x \
# 下载ibcp的最新war包
    && wget -r -np -nd -P ~/ibcp_packages --http-user="${PACKAGE_USER}" --http-password="${PACKAGE_PASSWORD}" "${PACKAGE_URL}/${PACKAGE_VERSION}" \
# 释放war包
    && (for file in `ls ~/ibcp_packages/ibcp.*.war`; \
       do \
# 修正war包的解压目录
         folder=${file##*ibcp.}; \
         folder=${folder%%.service*}; \
# 记录释放的目录到ibcp.release
         if [ ! -e "${CATALINA_HOME}/webapps/ibcp.release" ]; then echo >>"${CATALINA_HOME}/webapps/ibcp.release"; fi; \
         if [ `grep -q "${folder}" "${CATALINA_HOME}/webapps/ibcp.release"` ];then echo "${folder}" >>"${CATALINA_HOME}/webapps/ibcp.release"; fi; \
# 解压war包到tomcat目录
         unzip -o $file -d "${CATALINA_HOME}/webapps/${folder}"; \
# 删除配置文件，并映射到统一位置
         if [ -e "${CATALINA_HOME}/webapps/${folder}/WEB-INF/app.xml" ]; then \
           if [ ! -e "/root/ibcp/conf/app.xml" ]; then cp -f "${CATALINA_HOME}/webapps/${folder}/WEB-INF/app.xml" "/root/ibcp/conf/app.xml"; fi; \
           rm -f "${CATALINA_HOME}/webapps/${folder}/WEB-INF/app.xml"; \
           ln -s /root/ibcp/conf/app.xml "${CATALINA_HOME}/webapps/${folder}/WEB-INF/app.xml"; \
         fi; \
# 删除服务路由文件，并映射到统一位置
         if [ -e "${CATALINA_HOME}/webapps/${folder}/WEB-INF/service_routing.xml" ]; then \
           if [ ! -e "/root/ibcp/conf/service_routing.xml" ]; then cp -f "${CATALINA_HOME}/webapps/${folder}/WEB-INF/service_routing.xml" "/root/ibcp/conf/service_routing.xml"; fi; \
           rm -f "${CATALINA_HOME}/webapps/${folder}/WEB-INF/service_routing.xml"; \
           ln -s /root/ibcp/conf/service_routing.xml "${CATALINA_HOME}/webapps/${folder}/WEB-INF/service_routing.xml"; \
         fi; \

       done;) \
