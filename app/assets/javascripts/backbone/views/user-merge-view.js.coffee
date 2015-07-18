class RollFindr.Views.UserMergeView extends Backbone.View
  src: null
  dest: null
  destOriginal: null
  el: $('.show-user')
  events: {
    'click [data-copy-all]' : 'copyAll'
    'click [data-reset-all]' : 'resetAll'
    'click [data-copy-image]' : 'copyImage'
    'click [data-copy-name]' : 'copyName'
    'click [data-copy-rank]' : 'copyRank'
    'click [data-copy-birthdate]' : 'copyBirthdate'
    'click [data-copy-birthplace]' : 'copyBirthplace'
    'click [data-copy-lineage]' : 'copyLineage'
    'click [data-copy-gender]' : 'copyGender'
    'click [data-copy-description]' : 'copyDescription'
  }
  initialize: (options)->
    _.extend(this, _.pick(options, 'src', 'dest'))
    @destOriginal = @dest.clone()

    _.bindAll(this,
      'copyAll',
      'resetAll',
      'copyFields',
      'copyImage',
      'copyName',
      'copyRank',
      'copyBirthdate',
      'copyBirthplace',
      'copyLineage',
      'copyGender',
      'copyDescription',
      'setImage',
      'render')

  render: ->
    fields = Object.keys(@dest.attributes)
    _.each fields, (field)=>
      @$("[name='user[#{field}]']").val @dest.get(field)

  copyAll: ->
    @dest = @src.clone()
    @setImage(@dest.get('image'))
    @render()

  copyFields: ->
    names = [].slice.call(arguments)
    _.each names, (name)=>
      @dest.set name, @src.get(name)
    @render()

  setImage: (url)->
    @$('div.avatar').last().css('background-image', "url('#{url}')")

  copyImage: ->
    @setImage(@src.get('image'))
    @copyFields('image', 'image_tiny', 'image_large')

  copyName: ->
    @copyFields('name')

  copyRank: ->
    @copyFields('stripe_rank', 'belt_rank')

  copyBirthdate: ->
    @copyFields('birth_day', 'birth_month', 'birth_year')

  copyBirthplace: ->
    @copyFields('birth_place')

  copyLineage: ->
    @copyFields('lineal_parent_id')

  copyGender: ->
    @copyFields('gender')

  copyDescription: ->
    @copyFields('description')

  resetAll: ->
    @dest = @destOriginal.clone()
    @setImage(@dest.get('image'))
    @render()

