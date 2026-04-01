// 声明式 Pipeline
pipeline {
    // 选择执行节点
    agent {
        kubernetes {
            cloud 'itx'
            inheritFrom 'jenkins-agent'
        }
    }

    environment {
        CODEUP_REPO_URL = "https://ghfast.top/https://github.com/1980744819/zeroclaw.git"
        CODEUP_BRANCH = "dev"

        REPO_ADDR = "192.168.1.7:30002"
        PROJECT = "zeroclaw"
        IMAGE_REPO = "${REPO_ADDR}/${PROJECT}"
        NAMESPACE = "prod"
        GIT_CREDENTIAL_ID = "credential_github"
        HARBOR_CREDENTIAL_ID = "credential_harbor_admin"
    }

    stages {
        stage('Pull Code') {
            steps {
                echo "开始拉取仓库 ${CODEUP_REPO_URL} 分支 ${CODEUP_BRANCH}..."
                git(
                    url: "${CODEUP_REPO_URL}",
                    branch: "${CODEUP_BRANCH}",
                    credentialsId: "${GIT_CREDENTIAL_ID}",
                    changelog: false,
                    poll: false
                )
                script {
                    if (!env.GIT_COMMIT || env.GIT_COMMIT == 'null') {
                        env.GIT_COMMIT = sh(returnStdout: true, script: "git rev-parse HEAD").trim()
                    }
                    env.GIT_SHORT = sh(returnStdout: true, script: "git rev-parse --short HEAD").trim()
                    env.IMAGE_TAG = "${env.GIT_SHORT}"
                    env.FULL_IMAGE_NAME = "${IMAGE_REPO}:${IMAGE_TAG}"
                    echo "Commit: ${env.GIT_COMMIT}, Short: ${env.GIT_SHORT}"
                    echo "镜像标签：${IMAGE_TAG}"
                    echo "完整镜像名：${FULL_IMAGE_NAME}"
                }
                echo "代码拉取完成！"
            }
        }

        stage('Build Docker Image') {
            steps {
                container('podman') {
                    withCredentials([usernamePassword(credentialsId: "${HARBOR_CREDENTIAL_ID}", usernameVariable: 'HARBOR_USER', passwordVariable: 'HARBOR_PASS')]) {
                        sh '''
                            set -e
                            echo "登录 Harbor 镜像仓库..."
                            podman login --tls-verify=false -u "${HARBOR_USER}" -p "${HARBOR_PASS}" "${REPO_ADDR}"
                        '''
                    }

                    echo "开始构建镜像 ${FULL_IMAGE_NAME}..."
                    sh """
                        set -e
                        podman build -f ./Dockerfile.ubuntu \
                        --squash --network=host \
                        --tls-verify=false \
                        -t ${FULL_IMAGE_NAME} \
                        .
                    """
                    echo "镜像构建完成！"
                }
            }
        }

        stage('Push to Private Repo') {
            steps {
                container('podman') {
                    withCredentials([usernamePassword(credentialsId: "${HARBOR_CREDENTIAL_ID}", usernameVariable: 'HARBOR_USER', passwordVariable: 'HARBOR_PASS')]) {
                        sh '''
                            set -e

                            echo "登录 Harbor 镜像仓库..."
                            podman login --tls-verify=false -u "${HARBOR_USER}" -p "${HARBOR_PASS}" "${REPO_ADDR}"

                            echo "推送镜像 ${FULL_IMAGE_NAME} 到 Harbor..."
                            podman push --tls-verify=false "${FULL_IMAGE_NAME}"
                            echo "镜像推送完成！"
                        '''
                    }
                }
            }
        }

        stage('Helm Deploy') {
            steps {
                container('helm') {
                    sh '''
                    set -euo pipefail

                    echo "开始部署应用到 Kubernetes..."
                    helm upgrade --install zeroclaw ./k8s/zeroclaw \
                        --namespace ${NAMESPACE} --create-namespace \
                        --set image.repository=${IMAGE_REPO} \
                        --set image.tag=${IMAGE_TAG}
                    echo "应用部署完成！"
                    '''
                }
            }
        }
    }

    post {
        success {
            script {
                container('podman') {
                    echo "流水线构建成功，已推送镜像到私人仓库并完成部署！"
                    echo "镜像：${FULL_IMAGE_NAME}"
                    echo "开始清理本地构建的镜像..."
                    sh """
                        podman rmi ${FULL_IMAGE_NAME} || true
                    """
                    echo "本地镜像清理完成！"
                }
            }
        }
        failure {
            echo "流水线构建失败，请查看日志排查问题！"
        }
        always {
            echo "流水线执行完成！"
        }
    }
}
