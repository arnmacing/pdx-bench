# pdx-bench

Сборка ClickHouse с PDX-индексом (ветка `pdx-s3` форка [arnmacing/ClickHouse](https://github.com/arnmacing/ClickHouse))
и стенд для экспериментов. НИР, 3 семестр.

```
docker build -t pdx-ch .
docker run --rm pdx-ch clickhouse local --queries-file /bench/smoke.sql
```

`Jenkinsfile` пока собирает образ и гоняет smoke-тест. Когда появится стенд (`bench/vbench`),
команда в стадии `run` поменяется на `python3 -m vbench run <config>`.

Что нужно от сервера: том для ccache и датасетов между запусками, `--cpuset-cpus` на один сокет
во время замеров, `perf` с хоста для профилирования.
