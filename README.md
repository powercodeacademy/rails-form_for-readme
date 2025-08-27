# The form_with Helper

In modern Rails, the `form_with` helper replaces both `form_for` and `form_tag`. This lesson will guide you through why model-aware forms are better, how `form_with` works, and how to use it for editing records. We'll teach by contrasting manual forms with model-aware forms, and show how strong parameters keep your app secure.

## Drawbacks of Manual Forms (and form_tag)

Suppose you’re building a pet hamster social network, and you need a profile edit page with 100 fields. If you use a manual form or `form_tag`, you have to:

- Manually specify the form’s action and HTTP method
- Write repetitive code for each field, referencing `@hamster` and its attributes
- The form doesn’t know if it’s for creating or editing

Example using `form_tag`:

```erb
<%= form_tag post_path(@post), method: :patch do %>
  <label>Post title:</label><br>
  <%= text_field_tag :title, @post.title %><br>

  <label>Post description</label><br>
  <%= text_area_tag :description, @post.description %><br>

  <%= submit_tag "Update Post" %>
<% end %>
```

Problems:

- You must specify the path and method manually
- No automatic value-filling for new vs. edit
- Params are flat, not nested under a model

## Benefits of Model-Aware Forms (form_with)

`form_with` is the modern Rails way to build forms. It can be used for both model-backed and non-model-backed forms, and it automatically:

- Picks the correct action and HTTP verb (POST for new, PATCH for edit)
- Fills in field values from the model
- Nests params under the model name
- Keeps your code DRY and clean

### Model-backed form_with Example (Edit Post)

Let’s refactor the above form to use `form_with`:

```erb
<%= form_with model: @post, local: true do |form| %>
  <label>Post title:</label><br>
  <%= form.text_field :title %><br>

  <label>Post description</label><br>
  <%= form.text_area :description %><br>

  <%= form.submit "Update Post" %>
<% end %>
```

Key points:

- `model: @post` tells Rails to use RESTful conventions and fill in values
- `local: true` makes the form submit synchronously (not AJAX)
- The form’s action and method are set automatically

### Non-model-backed form_with Example (Search)

You can also use `form_with` for forms not tied to a model:

```erb
<%= form_with url: search_path, method: :get, local: true do |form| %>
  <%= form.text_field :query %>
  <%= form.submit "Search" %>
<% end %>
```

## How Rails Chooses PATCH vs. POST

When you use `form_with model: @post`, Rails checks if `@post` is a new record or an existing one:

- If `@post` is new (not saved), the form submits to the `create` action with `POST`
- If `@post` exists, the form submits to the `update` action with `PATCH`

This is automatic—no need to specify the method yourself!

## Params Structure and Strong Parameters

With manual forms, params look like this:

```rb
{
  "title" => "My Title",
  "description" => "My description"
}
```

With `form_with model: @post`, params are nested:

```rb
{
  "post" => {
    "title" => "My Title",
    "description" => "My description"
  }
}
```

This is why you need strong parameters in your controller:

```ruby
def update
  @post = Post.find(params[:id])
  if @post.update(post_params)
    redirect_to @post
  else
    render :edit
  end
end

private

def post_params
  params.require(:post).permit(:title, :description)
end
```

## Best Practices and Takeaways

- Use `form_with` for all forms in Rails 7+
- For model-backed forms, use `form_with model: @model, local: true`
- For standalone forms (like search), use `form_with url: ..., method: ..., local: true`
- Always use strong parameters to safely handle nested params
- `form_with` keeps your code DRY, secure, and up-to-date with Rails conventions

## Summary

`form_with` is now the Rails standard for building forms. It replaces both `form_for` and `form_tag`, and should be your default for new Rails apps. Use `form_with model: ...` for model-backed forms (like editing a Post), and `form_with url: ...` for standalone forms. Always use strong parameters to permit nested attributes. This approach keeps your forms clean, secure, and maintainable!
