class IndexController < ModelController
  model :page

  def initialize
    super

    # Add controller setup code here
    _todos << {_label: "prova", _completed: false}
    p _todos
    _toggle_all.on('changed') do |v|
      p ['_toggle_all changed', _toggle_all]
    end
  end

  def add_todo
    self._todos << {_label: page._new_label.cur, _completed: false}
  end

end
