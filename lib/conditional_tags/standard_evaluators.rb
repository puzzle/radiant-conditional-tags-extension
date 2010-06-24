module ConditionalTags
  module StandardEvaluators

    include Evaluatable


    evaluator "content" do |tag, element_info|
      part_name = element_info[:index] ||= 'body'
      if part = tag.locals.page.part(part_name)
        part.content
      end
    end


    evaluator "content.count", :index_not_permitted do |tag, element_info|
      tag.locals.page.parts.length
    end


    evaluator "parts", :index_not_permitted do |tag, element_info|
      tag.locals.page.parts.map { |part| part.name }
    end


    evaluator "site-mode", :index_not_permitted do |tag, element_info|
      if (dev_host = Radiant::Config['dev_host']) && (tag.globals.page.request.host == dev_host)
        "dev"
      elsif tag.globals.page.request.host =~ /^dev\./
        "dev"
      else
        "live"
      end
    end


    evaluator "status", :index_not_permitted do |tag, element_info|
      case tag.locals.page.status
        when Status[:draft]
          "draft"
        when Status[:reviewed]
          "reviewed"
        when Status[:published]
          "published"
        when Status[:hidden]
          "hidden"
        else
          "unknown"
      end
    end


    [:title, :slug, :url, :breadcrumb, :description, :keywords].each do |page_property|
      evaluator page_property, :index_not_permitted do |tag, element_info|
        tag.locals.page.send(page_property)
      end
    end


    evaluator "created-by", :index_not_permitted do |tag, element_info|
      tag.locals.page.created_by.name
    end


    evaluator "updated-by", :index_not_permitted do |tag, element_info|
      tag.locals.page.updated_by.name
    end


    evaluator "children", :index_not_permitted do |tag, element_info|
      tag.locals.page.children.map { |child| child.title }
    end


    evaluator "children.count", :index_not_permitted do |tag, element_info|
      tag.locals.page.children.length
    end

    evaluator "children.index" do |tag, element_info|
      kind = element_info[:index] ||= :current
      case kind.to_sym
        when :current
          index = 1
          tag.locals.paginated_children.each do |child|
            break if tag.locals.child == child
            index += 1
          end
          index
        when :last
          tag.locals.paginated_children.length
        else
          raise TagError.new(%{index of `children.index' evaluator must be set to either "current" or "last"})
      end
    end
  end
end
