-- проверка, что бинарь собрался с PDX и индекс работает
SELECT value FROM system.build_options WHERE name = 'USE_PDX';

CREATE TABLE t (id UInt32, v Array(Float32), INDEX idx v TYPE vector_similarity('pdx', 'L2Distance', 4))
ENGINE = MergeTree ORDER BY id;

INSERT INTO t SELECT number, [number, 0, 0, 0] FROM numbers(1000);

SELECT id FROM t ORDER BY L2Distance(v, [10., 0, 0, 0]) LIMIT 3;
