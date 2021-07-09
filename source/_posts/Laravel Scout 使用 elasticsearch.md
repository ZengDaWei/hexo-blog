---
title: Laravel Scout 使用 elasticsearch
date: 2021-7-19 20:03:26
categories: ElasticSearch
top_img: https://image.zdw1.cn/img20210709200505.png
cover: https://image.zdw1.cn/img20210709200505.png
tags:
  - Laravel
  - ElasticSearch
  - 搜索
  - 后端
---

# Laravel Scout 使用 elasticsearch

## Install Scout

```bash
$ composer require laravel/scout
$ php artisan vendor:publish --provider="Laravel\Scout\ScoutServiceProvider"
```

最后，在你要做搜索的模型中添加 `Laravel\Scout\Searchable` trait。这个 trait 会注册一个模型观察者来保持模型和所有驱动的同步：

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Laravel\Scout\Searchable;

class Movie extends Model
{
    use Searchable;
}
```

## Install ElasticSearch on Ubuntu

Elasticsearch 软件包和 OpenJDK 一起打包，所以不需要去安装 Java。

```bash
$ sudo apt update
$ sudo apt install apt-transport-https ca-certificates wget
```

导入软件源的 GPG key：

```bash
$ wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
```

上面的命令应该会输出`OK`,它意味着 key 已经被成功导入，这个软件源的软件包也被认为是被信任的。

下一步， 添加 Elasticsearch 软件源 到系统， 输入：

```bash
sudo sh -c 'echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" > /etc/apt/sources.list.d/elastic-7.x.list'
```

一旦软件源被启用，输入下面的命令，安装 Elasticsearch

```bash
$ sudo apt update
$ sudo apt install elasticsearch
```

Elasticsearch 服务在安装完成后不会自动启动。想要启动服务，并且启用开机启动：

```bash
sudo systemctl enable --now elasticsearch.service
```

想要验证 Elasticsearch 正在运行，使用`curl`来发送一个 HTTP 请求给端口`9200`

```bash
curl -X GET "localhost:9200/"
```

响应结果:

```json
{
  "name" : "jp003",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "yrHoR71vQkyxeRdkun0EXg",
  "version" : {
    "number" : "7.13.2",
    "build_flavor" : "default",
    "build_type" : "deb",
    "build_hash" : "4d960a0733be83dd2543ca018aa4ddc42e956800",
    "build_date" : "2021-06-10T21:01:55.251515791Z",
    "build_snapshot" : false,
    "lucene_version" : "8.8.2",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
```

You Know, for Search

想要查看由 Elasticsearch 服务记录的消息，使用下面的命令

```bash
$ sudo journalctl -u elasticsearch
```

### 配置 ES Search 远程访问

使用 `iptables`检查 9200（或是你指定的端口）是否开启。

如果没有开启，使用 `vim /etc/iptables/rules.v4` 打开端口

在确认开启之后，修改文件 `sudo nano /etc/elasticsearch/elasticsearch.yml`

搜索包括`network.host`的这一行，取消它的注释，并且修改值为`0.0.0.0`

```bash
network.host: 0.0.0.0
```

重启 Elasticsearch 服务，使得应用生效

```bash
sudo systemctl restart elasticsearch
```

## 配置 ES search IK 中文分词

Github:https://github.com/medcl/elasticsearch-analysis-ik

进入到你的 ES Search 的目录

```bash
$ /usr/share/elasticsearch/bin
```

使用 `elasticsearch-plugin`来安装 IK 分词器

```bash
$ ./elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v6.3.0/elasticsearch-analysis-ik-6.3.0.zip
```

重启

```bash
$ sudo systemctl restart elasticsearch
```

#### 测试

创建测试 Index

```bash
$ curl -XPUT http://localhost:9200/index
```

创建测试 Mapping

```bash
$ curl -XPOST http://localhost:9200/index/_mapping -H 'Content-Type:application/json' -d'
{
        "properties": {
            "content": {
                "type": "text",
                "analyzer": "ik_max_word",
                "search_analyzer": "ik_smart"
            }
        }

}'
```

向 Index 填充测试数据

```bash
$ curl -XPOST http://localhost:9200/index/_create/1 -H 'Content-Type:application/json' -d'
{"content":"美国留给伊拉克的是个烂摊子吗"}
'
```

```bash
$ curl -XPOST http://localhost:9200/index/_create/2 -H 'Content-Type:application/json' -d'
{"content":"公安部：各地校车将享最高路权"}

```

```bash
$ curl -XPOST http://localhost:9200/index/_create/4 -H 'Content-Type:application/json' -d'
{"content":"中国驻洛杉矶领事馆遭亚裔男子枪击 嫌犯已自首"}
'
```

```bash
$ curl -XPOST http://localhost:9200/index/_search  -H 'Content-Type:application/json' -d'
{
    "query" : { "match" : { "content" : "中国" }},
    "highlight" : {
        "pre_tags" : ["<tag1>", "<tag2>"],
        "post_tags" : ["</tag1>", "</tag2>"],
        "fields" : {
            "content" : {}
        }
    }
}
'
```

## 配置 Scout Driver 为 ES search

使用扩展包：`https://github.com/babenkoivan/scout-elasticsearch-driver`

```bash
$ composer require babenkoivan/scout-elasticsearch-driver
```

```bash
$ php artisan vendor:publish --provider="ScoutElastic\ScoutElasticServiceProvider"
```

然后，将`.env`中的 `SCOUT_DRIVER`设置为`elastic`

```bash
SCOUT_DRIVER=elastic
```

### 配置索引

使用`artisan`去创建 `es search` 索引

```bash
php artisan make:index-configurator Es/MovieIndexConfigurator
```

```php
<?php

namespace App\Es;

use ScoutElastic\IndexConfigurator;
use ScoutElastic\Migratable;

class MovieIndexConfigurator extends IndexConfigurator
{
    use Migratable;
    protected $name = 'movies';
    /**
     * @var array
     */
    protected $settings = [
        //
    ];
}
```

`$name` 对应索引名称，设置成想要的名称。

### 创建索引

```bash
$ php artisan elastic:create-index "App\Es\MovieIndexConfigurator"
```

### 配置到模型

```bash
$ php artisan make:searchable-model Movie --index-configurator=Es\MovieIndexConfigurator
```

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use ScoutElastic\Searchable;

class Movie extends Model
{
    use Searchable;

    protected $table             = 'movies';
    public $timestamps           = true;
    protected $indexConfigurator = \App\Es\MovieIndexConfigurator::class;

    protected $mapping = [
        'properties' => [
            'name'     => [
                'type'            => 'text',
                'analyzer'        => 'ik_smart',
                'search_analyzer' => 'ik_smart',
            ],
            'producer' => [
                'type'            => 'text',
                'analyzer'        => 'ik_smart',
                'search_analyzer' => 'ik_smart',
            ],
            'actors'   => [
                'type'            => 'text',
                'analyzer'        => 'ik_smart',
                'search_analyzer' => 'ik_smart',
            ],
        ],
    ];

    public function toSearchableArray()
    {
        return [
            'name'     => $this->name,
            'actors'   => $this->actors,
            'producer' => $this->producer,
        ];
    }
}
```

### 同步到`ES Search`

```bash
$ php artisan elastic:update-mapping "App\Models\Movie"
```

## 使用

### 基础使用

```php
Movie::search($keyword)->get();
```

### 进阶使用

从 ReadMe 复制

```php
// set query string
App\MyModel::search('phone')
    // specify columns to select
    ->select(['title', 'price'])
    // filter
    ->where('color', 'red')
    // sort
    ->orderBy('price', 'asc')
    // collapse by field
    ->collapse('brand')
    // set offset
    ->from(0)
    // set limit
    ->take(10)
    // get results
    ->get();
```

该扩展包提供了许多 Laravel Model 与 `Es Search`的搜索自定义函数，详情阅读：`https://github.com/babenkoivan/scout-elasticsearch-driver`
