defmodule LedgerRecord do
  defstruct [:type, :timestamp, :user_id, :amount] 
end

defmodule Proto do

  def function do
    value = File.read!("txnlog.dat")

    # | 4 byte magic string "MPS7" | 1 byte version | 4 byte (uint32) # of records |
    << "MPS7", 
       _version :: binary-size(1), 
       _record_count :: size(32), 
       data :: binary >> = value

    details = []

    process_data(data, details)
  end

  def process_data(<< <<0>>, timestamp::integer-size(32), user_id::integer-size(64), amount::float, rest::binary>>, details) do
    details = details ++ [%LedgerRecord{type: :debit, timestamp: timestamp, user_id: user_id, amount: amount}]
    process_data(rest, details)
  end

  def process_data(<< <<1>>, timestamp::integer-size(32), user_id::integer-size(64), amount::float, rest::binary>>, details) do
    details = details ++ [%LedgerRecord{type: :credit, timestamp: timestamp, user_id: user_id, amount: amount}]
    process_data(rest, details)
  end

  def process_data(<< <<2>>, timestamp::integer-size(32), user_id::integer-size(64), rest::binary>>, details) do
    details = details ++ [%LedgerRecord{type: :start_autopay, timestamp: timestamp, user_id: user_id}]
    process_data(rest, details)
  end

  def process_data(<< <<3>>, timestamp::integer-size(32), user_id::integer-size(64), rest::binary>>, details) do
    details = details ++ [%LedgerRecord{type: :end_autopay, timestamp: timestamp, user_id: user_id}]
    process_data(rest, details)
  end

  def process_data("", details) do
    IO.puts "* What is the total amount in dollars of debits?"
    Enum.filter_map(details, fn(ledger) ->
      ledger.type == :debit
    end, fn(ledger) ->
      ledger.amount
    end)
    |> Enum.sum
    |> IO.puts

    IO.puts "* What is the total amount in dollars of credits?"
    Enum.filter_map(details, fn(ledger) ->
      ledger.type == :credit
    end, fn(ledger) ->
      ledger.amount
    end)
    |> Enum.sum
    |> IO.puts

    IO.puts "* How many autopays were started?"
    Enum.filter(details, fn(ledger) ->
      ledger.type == :start_autopay
    end)
    |> Enum.count
    |> IO.puts

    IO.puts "* How many autopays were ended?"
    Enum.filter(details, fn(ledger) ->
      ledger.type == :end_autopay
    end)
    |> Enum.count
    |> IO.puts

    IO.puts "* What is balance of user ID 2456938384156277127?"
    Enum.filter_map(details, fn(ledger) ->
      ledger.user_id == 2456938384156277127
    end, fn(ledger) ->
      case ledger.type do
        :debit ->
          -1 * ledger.amount
        :credit ->
          ledger.amount
        true ->
          0
      end
    end)
    |> Enum.sum
    |> IO.puts

  end
end

Proto.function