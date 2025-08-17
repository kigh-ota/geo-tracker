-- ヘルスチェック用のRPC関数を作成
CREATE OR REPLACE FUNCTION health_check()
RETURNS TABLE(status TEXT)
LANGUAGE sql
AS $$
  SELECT 'ok'::TEXT as status;
$$;