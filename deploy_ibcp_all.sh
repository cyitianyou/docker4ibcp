#!/bin/bash
echo '****************************************************************************'
echo '         deploy_ibcp_all.sh                                                 '
echo '                      by niuren.zhu                                         '
echo '                           2016.10.20                                       '
echo '  说明：                                                                    '
echo '    1. 下载ibcp所有模块并解压，默认从ibas.club:8866下载。                   '
echo '    2. 参数1，下载模块释放的目录。                                          '
echo '    3. 添加PATH变量到%MAVEN_HOME%\bin，并检查JAVE_HOME配置是否正确。        '
echo '    4. 运行提示符运行mvn -v 检查安装是否成功。                              '
echo '    5. 此脚本会遍历当前目录的子目录，查找pom.xml并编译jar包到release目录。  '
echo '    6. 可在compile_order.txt文件中调整编译顺序。                            '
echo '****************************************************************************'
# 定义变量
# ibcp工作目录
IBCP_WORK_FOLDER=$PWD
# 程序包-发布服务地址
IBCP_PACKAGE_URL=http://ibas.club:8866/ibcp
# 程序包-发布服务用户名
IBCP_PACKAGE_USER=avatech/\amber
# 程序包-发布服务用户密码
IBCP_PACKAGE_PASSWORD=Aa123456
# 程序包-版本路径
IBCP_PACKAGE_VERSION=latest
# 程序包-下载目录
IBCP_PACKAGE_DOWNLOAD=${IBCP_WORK_FOLDER}/ibcp_packages/$(date +%s)
# ibcp配置目录
IBCP_CONF=${IBCP_WORK_FOLDER}/conf
# ibcp数据目录
IBCP_DATA=${IBCP_WORK_FOLDER}/data
# ibcp日志目录
IBCP_LOG=${IBCP_WORK_FOLDER}/log
# 释放的目录
DEPLOY_FOLDER=$1
# 未提供释放目录则为当前目录
if [ "${DEPLOY_FOLDER}"=="" ];then DEPLOY_FOLDER=$PWD; fi;

# 初始化环境
mkdir -p "${IBCP_PACKAGE_DOWNLOAD}"
mkdir -p "${IBCP_CONF}"
mkdir -p "${IBCP_DATA}"
mkdir -p "${IBCP_LOG}"

# 下载ibcp
echo 开始下载模块，从${IBCP_PACKAGE_URL}/${IBCP_PACKAGE_VERSION}/
wget -r -np -nd -nv -P ${IBCP_PACKAGE_DOWNLOAD} --http-user=${IBCP_PACKAGE_USER} --http-password=${IBCP_PACKAGE_PASSWORD} ${IBCP_PACKAGE_URL}/${IBCP_PACKAGE_VERSION}/
echo 开始解压模块，到目录${CATALINA_HOME}
for file in `ls "${IBCP_PACKAGE_DOWNLOAD}" | grep .war`
  do
    echo 释放${file}
# 修正war包的解压目录
    folder=${file##*ibcp.}
    folder=${folder%%.service*}
# 记录释放的目录到ibcp.release
    if [ ! -e "${DEPLOY_FOLDER}/ibcp.release" ]; then echo >>"${DEPLOY_FOLDER}/ibcp.release"; fi
    if [ `grep -q "${folder}" "${DEPLOY_FOLDER}/ibcp.release"` ];then echo "${folder}" >>"${DEPLOY_FOLDER}/ibcp.release"; fi;
# 解压war包到目录
    unzip -o "${IBCP_PACKAGE_DOWNLOAD}/${file}" -d "${DEPLOY_FOLDER}/${folder}"
# 删除配置文件，并映射到统一位置
    if [ -e "${DEPLOY_FOLDER}/${folder}/WEB-INF/app.xml" ]; then
      if [ ! -e "${IBCP_CONF}/app.xml" ]; then cp -f "${DEPLOY_FOLDER}/${folder}/WEB-INF/app.xml" "${IBCP_CONF}/app.xml"; fi;
      rm -f "${DEPLOY_FOLDER}/${folder}/WEB-INF/app.xml"
      ln -s "${IBCP_CONF}/app.xml" "${DEPLOY_FOLDER}/${folder}/WEB-INF/app.xml"
    fi;
# 删除服务路由文件，并映射到统一位置
    if [ -e "${DEPLOY_FOLDER}/${folder}/WEB-INF/service_routing.xml" ]; then
      if [ ! -e "${IBCP_CONF}/service_routing.xml" ]; then cp -f "${DEPLOY_FOLDER}/${folder}/WEB-INF/service_routing.xml" "${IBCP_CONF}/service_routing.xml"; fi;
      rm -f "${DEPLOY_FOLDER}/${folder}/WEB-INF/service_routing.xml"
      ln -s "${IBCP_CONF}/service_routing.xml" "${DEPLOY_FOLDER}/${folder}/WEB-INF/service_routing.xml"
    fi
# 映射日志文件夹到统一位置
    if [ -e "${DEPLOY_FOLDER}/${folder}/WEB-INF/log" ]; then rm -rf "${DEPLOY_FOLDER}/${folder}/WEB-INF/log"; fi;
    ln -s -d "${IBCP_LOG}" "${DEPLOY_FOLDER}/${folder}/WEB-INF/"
  done
echo 操作完成
