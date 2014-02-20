module Kernel
  def pp *args
    args.each do |arg|
      `console.log(#{arg}, '---');`
    end
    return *args
  end
end


module LocalStorage
  def self.[](key)
    %x{
      var val = localStorage.getItem(key);
      return val === null ? nil : val;
    }
  end

  def self.[]=(key, value)
    `localStorage.setItem(key, value)`
  end

  def self.clear
    `localStorage.clear()`
    self
  end

  def self.delete(key)
    %x{
      var val = localStorage.getItem(key);
      localStorage.removeItem(key);
      return val === null ? nil : val;
    }
  end
end if RUBY_PLATFORM == 'opal'

require 'volt/models/persistors/base'

module Persistors
  class LocalStorage < Base
    def initialize(model)
      pp [:got_model, model]
      @model = model
      @key = "volt-persistor-#{model.class}-#{model.object_id}"
      pp [:loading_attrs, @key]
      model.attributes = loaded_attributes
      pp [:loaded_attrs, loaded_attributes.to_h.cur.to_json]
    end

    def loaded_attributes
      JSON.parse(::LocalStorage[@key] || '{}')
    end

    def changed(attribute_name)
      json = (model.cur || {}).to_h.cur.to_json
      pp [:local_storage_changed, attribute_name, json]
      ::LocalStorage[@key] = json
    end
  end
end

class IndexController < ModelController
  def initialize
    pp 'ooooooooooooooo'
    local_storage = ReactiveValue.new(Model.new({}, persistor: Persistors::LocalStorage))
    pp 'iiiiiiiiiiiiiii'
    $local_storage = local_storage
    @model = local_storage
    _todos << {_label: "prova", _completed: false}
    pp 'llllllllll'
  end

  def _new_label
    page._new_label
  end

  def _new_label=v
    page._new_label=v
  end

  def toggle_all
    all_completed = _todos.all? &:_completed?
    _todos.each {|t| t._completed = !all_completed}
    self._toggle_all = !all_completed
  end

  def new_todo_keyup(event)
    add_todo if event.key_code == 13
  end

  def add_todo
    _todos << {_label: self._new_label.cur, _completed: false}
    self._new_label = ''
    pp _todos.last.cur.inspect
    @model.trigger 'changed'
  end
end
