pipeline {
    agent any

    parameters {
        string(name: 'CONFIG', defaultValue: 'configs/stage3_pilot.yaml', description: 'какой эксперимент гонять (пока не используется, см. README)')
        string(name: 'CPUSET', defaultValue: '0-23', description: 'ядра одного сокета, см. lscpu')
    }

    options {
        disableConcurrentBuilds()   // одновременно только один прогон, иначе замеры шумят
    }

    stages {
        stage('build') {
            steps {
                sh 'docker build -t pdx-ch .'
            }
        }

        stage('run') {
            steps {
                sh """
                    docker run --rm \
                        --cpuset-cpus ${params.CPUSET} --cpuset-mems 0 \
                        -v pdx-datasets:/data \
                        -v ${WORKSPACE}/results:/results \
                        pdx-ch clickhouse local --queries-file /bench/smoke.sql
                """
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'results/**', allowEmptyArchive: true
        }
    }
}
