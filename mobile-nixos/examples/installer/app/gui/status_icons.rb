# Multiple icons for the status bar
class GUI::StatusIcons < LVGUI::Widget

  # Multiple instances of windows may be refreshing the data at once.
  # This is the main reason we're "caching" this; single-threaded access
  # to nmcli can be slow...
  class Data
    include Singleton

    # The data will be updated not more frequently than this many seconds.
    DATA_UPDATE_DELAY = 10

    def initialize()
      @last_refresh = Time.new(0)
    end

    def get_data()
      return @cached_data if @last_refresh > Time.now()
      @last_refresh = Time.now() + DATA_UPDATE_DELAY

      @cached_data = [
        :usb,
        :wired,
        :wifi,
        :battery,
      ]
        .map do |sym|
          [sym, send(:"data_#{sym}")]
        end
        .to_h
    end

    private

    def data_battery()
      @battery ||= LVGUI::HAL::Battery.main_battery

      if @battery
        symbol =
          if @battery.charging? then
            LVGL::Symbols::CHARGE
          elsif @battery.percent == "unknown"
            ""
          elsif @battery.percent > 95
            LVGL::Symbols::BATTERY_FULL
          elsif @battery.percent > 75
            LVGL::Symbols::BATTERY_3
          elsif @battery.percent > 45
            LVGL::Symbols::BATTERY_2
          elsif @battery.percent > 10
            LVGL::Symbols::BATTERY_1
          else
            LVGL::Symbols::BATTERY_EMPTY
          end

        "#{symbol} #{@battery.percent}%"
      else
        ""
      end
    end

    def data_usb()
      # TODO: USB icon if ever needed
      #"\uf287"
      ""
    end

    def data_wifi()
      if wifi = Hardware::Network.current_wifi.first
        percent = wifi[:signal]
        "\uf1eb#{percent}%"
      end
    end

    def data_wired()
      if wired = Hardware::Network.wired.first
        if wired[:state] == "connected"
          "\uf6ff"
        else
          # A wide-stanced slash.
          # TODO: make widgets independent labels, and make this specific
          #       widget two layered labels, and have the slash on top of
          #       the ethernet icon when interface is not connected.
          "\uf715"
        end
      end
    end
  end

  def initialize(parent)
    # TODO don't directly use label
    # Instead use a container in which we add multiple discrete widgets...
    # Those widgets can *then* be more complex like use SVG and such.
    super(LVGL::LVLabel.new(parent))
    set_align(LVGL::LABEL_ALIGN::RIGHT)
    set_long_mode(LVGL::LABEL_LONG::CROP)

    # Update the text once
    update_text

    # Then register a task to update regularly.
    @task = LVGL::Hacks::LVTask.create_task(1000 * 15, LVGL::TASK_PRIO::LOW, ->() do
      update_text
    end)
  end

  def update_text()
    txt = Data.instance.get_data.values.compact.join("  ")
    set_text(txt)
  end

  def del()
    LVGL::Hacks::LVTask.delete_task(@task)
    super()
  end
end
