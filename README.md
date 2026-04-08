# Terraform AWS Basic Infrastructure (Practice)

## 概要

本リポジトリは、Udemy教材をベースに Terraform を用いて AWS 環境を構築したものです。
CloudFront・ALB・EC2・RDS を組み合わせた基本的なWebアプリケーション構成を実装しています。

本構成は主に以下の理解を目的としています。

* Terraform によるインフラコード化
* AWS各サービスの連携構成
* セキュリティグループによる通信制御
* CloudFrontを用いた配信構成

---

## 構成概要

```
User
  ↓
CloudFront（HTTPS）
  ↓
ALB（HTTPS）
  ↓
EC2（AutoScaling）
  ↓
RDS（MySQL）

静的コンテンツ：S3（CloudFront経由のみアクセス可能）
```

---

## 使用サービス

* VPC / Subnet / Route Table
* Internet Gateway
* CloudFront
* Application Load Balancer（ALB）
* EC2（Launch Template + Auto Scaling Group）
* RDS（MySQL）
* S3（静的コンテンツ / デプロイ用）
* Route53
* ACM（東京 / バージニア）
* IAM / Security Group

---

## ネットワーク構成

* VPC: `192.168.0.0/20`
* Public Subnet（2AZ）

  * ALB / EC2配置
* Private Subnet（2AZ）

  * RDS配置
* Internet Gateway により Public Subnet のみ外部通信可能

※ Private Subnet には NAT Gateway を配置しておらず、外部通信を行わない前提のシンプル構成

---

## ドメイン構成

* CloudFront: `dev.${var.domain}`
* ALB: `dev-elb.${var.domain}`

---

## HTTPS構成

* CloudFront → ACM（us-east-1）

* ALB → ACM（ap-northeast-1）

* HTTPアクセスはHTTPSへリダイレクト

---

## CloudFront設計

* 動的コンテンツ（ALB）

  * キャッシュ無効（TTL=0）
* 静的コンテンツ（S3）

  * `/public/*` のみキャッシュ
* S3は OAI により CloudFront のみアクセス可能

---

## S3構成

### static bucket

* CloudFront配信用
* Public Access Block 有効
* OAI経由のみアクセス許可

### deploy bucket

* EC2用プライベートバケット
* IAMロールからのみアクセス許可

---

## セキュリティ設計

* ALB → EC2 のみ通信許可

* EC2 → RDS のみ通信許可

* セキュリティグループ連鎖による最小権限構成

* 管理アクセスは制限CIDRによるSSH接続を想定

※ 本構成では SSM(Session Manager) による接続は未実装

---

## IAM設計

* EC2にIAMロールを付与
* S3アクセスは必要最小限に制限

---

## 変数管理

主な変数は以下で管理しています。

* `project`
* `environment`（dev / stg / prod）
* `domain`
* `aws_region`
* `allowed_admin_cidr`

---

## Provider構成

* メインリージョン: ap-northeast-1（東京）
* CloudFront / ACM用: us-east-1（バージニア）

```hcl
provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}
```

---

## 起動方法

```bash
terraform init
terraform plan
terraform apply
```

---

## 補足

* 本リポジトリは学習目的で作成しており、本番利用は想定していません。
* 動的コンテンツはALBへ転送し、CloudFrontでは短時間キャッシュ（default_ttl: 60秒, max_ttl: 300秒）を設定しています。
* 静的コンテンツ(`/public/*`)はS3配信としてキャッシュを有効化しています。
* AMIは学習環境で作成したカスタムAMI（tastylog-*-ami）を参照しています。

---

## 学習ポイント

* TerraformによるAWSリソース管理
* CloudFront + ALB の構成理解
* セキュリティグループの設計
* IAMロールによるアクセス制御

---