defmodule AES.GCM do
  @aad "AES256GCM"

  def secret_key(), do: :application.get_env(:n2o, :secret, "ThisIsClassified")

  def depickle(hex) do
    try do
      cipher = :n2o_secret.unhex(hex)
      <<iv::binary-16, tag::binary-16, bin::binary>> = cipher
      term = :crypto.block_decrypt(:aes_gcm, secret_key(), iv, {@aad, bin, tag})
      :erlang.binary_to_term(term, [:safe])
    rescue
      _ -> ""
    end
  end

  def pickle(term) do
    bin = :erlang.term_to_binary(term)
    iv = :crypto.strong_rand_bytes(16)

    {cipher, tag} =
      :crypto.block_encrypt(:aes_gcm, secret_key(), iv, {@aad, bin})

    bin = iv <> tag <> cipher
    :n2o_secret.hex(bin)
  end
end
