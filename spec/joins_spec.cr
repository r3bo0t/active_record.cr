require "./spec_helper"

class PersonWithPostsJoinQuery < ActiveRecord::NullAdapter::JoinQuery
  def call(base_record, foreign_record)
    return  base_record &&
            foreign_record &&
            base_record["id"] == foreign_record["author_id"]
  end
end

ActiveRecord::NullAdapter.register_join_query(
  "people.id = posts.author_id",
  PersonWithPostsJoinQuery.new
)

class PersonWithPosts < ActiveRecord::Join
  one Person, id
  many Post, author_id
end

describe "joins" do
  it "allows to get one person with no posts" do
    # ARRANGE
    person = new_person.create

    # ACT
    actual = PersonWithPosts.get(person.id)

    # ASSERT
    actual.person.should eq(person)
  end

  it "allows to get one person with one posts" do
    # ARRANGE
    person = new_person.create
    post = Post.create({
      "title" => "hello",
      "content" => "world",
      "author_id" => person.id
    })

    # ACT
    actual = PersonWithPosts.get(person.id)

    # ASSERT
    actual.person.should eq(person)
    actual.posts.should eq([post])
  end
end