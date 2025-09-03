# Rails Forms: From form_tag to form_for (and Beyond)

In this lesson, you'll learn why model-aware forms are better, how to refactor from `form_tag` to `form_for`, and how Rails conventions make your code DRY and maintainable. We'll teach by contrasting manual forms with model-aware forms, and show how strong parameters keep your app secure.

## Recap: What Does form_tag Look Like?

Suppose you’re building a pet hamster social network, and you need a profile edit page with many fields. With `form_tag`, you have to:

## Issues with using `form_tag`

Before we get into the benefits and features of the `form_for` method, let's
first discuss some of the key drawbacks to utilizing `form_tag`:

- Our form must be manually passed to the route where the form parameters will
  be submitted

- The form has no knowledge of the form's goal; it doesn't know if the form is
  meant to create or update a record

- You're forced to have duplicate code throughout the form; it's hard to adhere
  to DRY principles when utilizing the `form_tag`

## Difference between `form_for` and `form_tag`

The differences between `form_for` and `form_tag` are subtle, but important.
Below is a basic breakdown of the differences. We'll start with talking about
them at a high level perspective and then get into each one of the aspects on a
practical/implementation basis:

- The `form_for` method accepts the instance of the model as an argument. Using
  this argument, `form_for` is able to make a bunch of assumptions for you.

- `form_for` yields an object of class `FormBuilder`

- `form_for` automatically knows the standard route (it follows RESTful
  conventions) for the form data as opposed to having to manually declare it

- `form_for` gives the option to dynamically change the `submit` button text
  (this comes in very handy when you're using a form partial and the `new` and
  `edit` pages will share the same form, but more on that in a later lesson)

A good rule of thumb for when to use one approach over the other is below:

- Use `form_for` when your form is directly connected to a model. Extending our
  example from the introduction, this would be our Hamster's profile edit form
  that connects to the profile database table. This is the most common case when
  `form_for` is used

- Use `form_tag` when you simply need an HTML form generated. Examples of this
  would be: a search form field or a contact form

## Implementation of `form_for`

Let's take the `edit` form that utilized the `form_tag` that we built before for
`posts` and refactor it to use `form_for`. As a refresher, here is the
`form_tag` version:

```erb
<%= form_tag post_path(@post), method: :patch do %>
  <label for="title">Post title:</label><br>
  <%= text_field_tag :title, @post.title, id: "title" %><br>

  <label for="description">Post description</label><br>
  <%= text_area_tag :description, @post.description, id: "description" %><br>

  <%= submit_tag "Submit Post" %>
<% end %>
```

## Problems with form_tag

- Lots of repetitive boilerplate (not DRY)
- You must specify the path and method manually
- No automatic value-filling for new vs. edit
- Params are flat, not nested under a model

## form_tag vs form_for: Side-by-Side Comparison

| Feature | form_tag | form_for |
|---------|----------|----------|
| Arguments | Route/path | Model instance |
| Knows whether it’s “new” or “edit”? | ❌ | ✅ (infers from record state) |
| Field helpers | text_field_tag :title, @post.title | f.text_field :title |
| Params structure | Flat (params[:title]) | Nested (params[:post][:title]) |
| Best use case | Non-model forms (search, contact, login) | Model-backed forms (new/edit resources) |

## Refactor Example: Edit Form Step by Step

Let’s refactor the above form to use `form_for`:

```erb
<%= form_for @post do |f| %>
  <%= f.label :title, "Post title:" %><br>
  <%= f.text_field :title %><br>

  <%= f.label :description, "Post description" %><br>
  <%= f.text_area :description %><br>

  <%= f.submit "Update Post" %>
<% end %>
```

Our refactor work isn't quite done. If you had previously created a `PUT` route
like we did in the `form_tag` lesson, we'll need to change that to a `PATCH`
method since that is the HTTP verb that `form_for` utilizes. We can make that
change in the `config/routes.rb` file:

- `@post` tells Rails to use RESTful conventions and fill in values
- The form's action and method are set automatically (PATCH for updates)
- The code is much DRYer and easier to maintain
- `f.label` generates a semantic label tag, automatically associating it with the correct input field for accessibility

## Strong Parameters: Why Are They Needed?

Because `form_for` is bound directly with the `Post` model, we need to pass the
model name into the Active Record `update` method in the controller. Let's
change `@post.update(title: params[:title], description: params[:description])`
to:

```ruby
@post.update(params.require(:post).permit(:title, :description))
```

So, why do we need to `require` the `post` model? If you look at the old form,
the `params` would look something like this:

```rb
{
  "title": "My Title",
  "description": "My description"
}
```

With `form_for`, params are nested:

```rb
{
  "post": {
    "title": "My Title",
    "description": "My description"
  }
}
```

### Controller Update: Old vs New

```ruby
# Old form_tag version
@post.update(title: params[:title], description: params[:description])

# New form_for version
@post.update(params.require(:post).permit(:title, :description))
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

## New Form Example and Shared Partials

One of the biggest benefits of `form_for` is that you can use the same form partial for both new and edit actions. Rails will automatically use POST for new records and PATCH for existing ones.

**_form.html.erb (shared partial):**

```erb
<%= form_for @post do |f| %>
  <%= f.label :title, "Post title:" %><br>
  <%= f.text_field :title %><br>

  <%= f.label :description, "Post description" %><br>
  <%= f.text_area :description %><br>

  <%= f.submit %>
<% end %>
```

Here, `f.label :title, "Post title:"` creates a semantic label tag for the title field, automatically associating it with the corresponding input. This improves accessibility and ensures screen readers and browsers can correctly identify the form fields.

**new.html.erb:**

```erb
<h3>New Post</h3>
<%= render 'form' %>
```

**edit.html.erb:**

```erb
<h3>Edit Post</h3>
<%= render 'form' %>
```

## Routes: Rails Handles PATCH for Updates

You only need:

```ruby
resources :posts, only: [:index, :show, :new, :create, :edit, :update]
```

Rails will generate the correct PATCH route for updates automatically.

## Summary & Best Practices

- `form_for` reduces repetition and boilerplate
- Automatically binds forms to models and chooses the right HTTP verb
- Works seamlessly with strong parameters
- Encourages reusable form partials for new/edit
- Use `form_tag` for non-model forms (like search or login)

**Key takeaway:** Model-aware forms are the Rails convention for a reason—they keep your code DRY, secure, and easy to maintain!
