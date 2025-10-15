-- Agregar columna user_id a la tabla vehicles
ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);

-- Actualizar vehículos existentes para asignarlos al primer usuario (temporal)
-- Esto es solo para desarrollo. En producción, deberías migrar los datos correctamente.
-- UPDATE vehicles SET user_id = (SELECT id FROM auth.users LIMIT 1) WHERE user_id IS NULL;

-- Habilitar Row Level Security (RLS)
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;

-- Crear política: Los usuarios solo pueden ver sus propios vehículos
CREATE POLICY "Users can view their own vehicles"
ON vehicles
FOR SELECT
USING (auth.uid() = user_id);

-- Crear política: Los usuarios solo pueden insertar vehículos para sí mismos
CREATE POLICY "Users can insert their own vehicles"
ON vehicles
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Crear política: Los usuarios solo pueden actualizar sus propios vehículos
CREATE POLICY "Users can update their own vehicles"
ON vehicles
FOR UPDATE
USING (auth.uid() = user_id);

-- Crear política: Los usuarios solo pueden eliminar sus propios vehículos
CREATE POLICY "Users can delete their own vehicles"
ON vehicles
FOR DELETE
USING (auth.uid() = user_id);

-- Crear índice para mejorar el rendimiento de las consultas por user_id
CREATE INDEX IF NOT EXISTS vehicles_user_id_idx ON vehicles(user_id);
