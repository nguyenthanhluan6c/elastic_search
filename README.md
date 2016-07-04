# Elastic search
Ngày nay, Elasticsearch không còn là khái niệm xa lạ với lập trình viên về web. Elasticsearch thực chất là một server chạy trên nền tàng Apache Lucene, cung cấp API cho công việc lưu trữ tìm kiếm dữ liệu một cách rất nhanh chóng. Điểm mạnh của Elasticsearch chính là tính phân tán cũng như khả năng mở rộng rất tốt của nó.

Indexing

Câu hỏi : Elasticsearch được gọi là real-time search bởi vì khả năng trả lại kết quả tìm kiếm của nó là nhanh chóng, vậy nó hoạt động như nào để có thể được gọi là real-time search?

Trả lời : Thay vì search text, Elasticsearch nó search index, cơ chế này gọi là inverted index

Ví dụ bây h ta tìm kiếm một từ nào đó trong một cuốn sách thì :

Search kiểu hàng ngày : lật từng trang và tìm kiếm từng từ trong mỗi trang. tìm trang -> ra text
Search kiểu inverted index : lật ngay tới phụ lục (Index table) và tìm các trang có chứa từ đó. tìm text -> ra trang.
Indexes là cơ chế dùng để tìm kiếm nhanh hơn các record trong databse, tránh việc phải đọc toàn bộ các record trong một table



Vậy khi tìm kiếm một bản ghi nào đó trong DB thay vì phải duyệt toàn bộ các bản ghi trong table thì ta sẽ dựa vào index để tìm ra những bản ghi được nhanh hơn, giống như cơ chế tìm một từ trong cuốn sách như trên.


## Implement
1. Install elastic-server

    *   Step 1. Install java

      >       sudo apt-get update
      >       sudo apt-get install openjdk-7-jre

    *  Step 2. Install elastic search

      >       wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.7.2.deb
      >       sudo dpkg -i elasticsearch-1.7.2.deb
      >       sudo update-rc.d elasticsearch defaults
      >       curl -X GET 'http://localhost:9200'

2. Implement in rails
    *   Step 1: Cai dat Gem

    >      gem 'elasticsearch-model'
    >      gem 'elasticsearch-rails'

    * Step 2: Tạo file:  concerns/searchable.rb

      >       require 'elasticsearch/model'
      >       module Searchable
      >         extend ActiveSupport::Concern
      >         included do
      >           include Elasticsearch::Model
      >           include Elasticsearch::Model::Callbacks
      >           def self.search_by(type, query)
      >             self.search("#{type}:#{query}")
      >           end
      >         end
      >       end

    * Include Searchable Model vào model

      >       class User < ActiveRecord::Base
      >       include Searchable
      >         ...
      >       end

    * Tạo lib/tasks/elasticsearch.rake và add đoạn code sau:

      >     require 'elasticsearch/rails/tasks/import'

    * Chạy rake để import data vào index

      > rake environment elasticsearch:import:all

    * Nếu chỉ muốn index một số fields nhất định của Model để giảm bộ nhớ cho ElasticSearch

      >       class User < ActiveRecord::Base
      >         include Searchable
      >         def as_indexed_json(options = {})
      >           self.as_json({
      >             only: [:name, :email],
      >             include: {
      >               books: { only: :name }
      >             }
      >           })
      >          end
      >       end

    * Test

      > User.search("user*2").records.to_a

3. Demo app
  ##  Steps to run.
  > 1. bundle
  > 2. rake db:migrate
  > 3. rake db:seed
  > 4. rake environment elasticsearch:import:all
  > 5. rails c
  >   * User.search("user*2").records.to_a
