
import 'package:flutter/material.dart';


class EditarPerfilPage extends StatefulWidget {
	final Map<String, dynamic>? initialData;
	
	const EditarPerfilPage({super.key, this.initialData});
	
	@override
	State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
	final _formKey = GlobalKey<FormState>();
	// Datos del usuario que se pueden editar
	late String _nombre;
	late String _username;
	late String _posicion;
	late String _edad;
	late String _equipo;
	late String _altura;
	late String _peso;
	
	@override
	void initState() {
		super.initState();
		// Inicializar con datos proporcionados o valores por defecto
		_nombre = widget.initialData?['nombre'] ?? 'Daniel Rodriguez';
		_username = '@daniel_jr10'; // Este campo no se edita desde perfil
		_posicion = widget.initialData?['posicion'] ?? 'Delantero';
		_edad = widget.initialData?['edad']?.toString() ?? '20';
		_equipo = widget.initialData?['club'] ?? 'FC Barcelona Academy';
		_altura = widget.initialData?['altura'] != null 
			? '${widget.initialData!['altura']}m' 
			: '1.80m';
		_peso = widget.initialData?['peso'] != null 
			? '${widget.initialData!['peso']}kg' 
			: '75kg';
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.grey[50],
			appBar: AppBar(
				leading: IconButton(
				  icon: const Icon(Icons.arrow_back, color: Color(0xFF00f5ff)),
				  onPressed: () => Navigator.of(context).pop(),
				),
				title: const Text(
				  'Editar Perfil',
				  style: TextStyle(
				    color: Color(0xFF00f5ff),
				    fontWeight: FontWeight.bold,
				  ),
				),
				backgroundColor: const Color(0xFF1a1a2e),
				elevation: 0,
			),
			body: SingleChildScrollView(
				child: Padding(
					padding: const EdgeInsets.all(16.0),
					child: Form(
						key: _formKey,
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.center,
							children: [
								// Avatar editable
								Stack(
									children: [
										Container(
											decoration: BoxDecoration(
												shape: BoxShape.circle,
												border: Border.all(
													color: const Color(0xFF00f5ff),
													width: 3,
												),
												boxShadow: [
													BoxShadow(
														color: const Color(0xFF1565C0).withValues(alpha: 0.2),
														blurRadius: 10,
														offset: const Offset(0, 3),
													),
												],
											),
											child: const CircleAvatar(
												radius: 50,
												backgroundColor: Color(0xFF1a1a2e),
												child: Icon(
													Icons.person,
													size: 60,
													color: Color(0xFF00f5ff),
												),
											),
										),
										Positioned(
											bottom: 5,
											right: 5,
											child: Container(
												decoration: BoxDecoration(
													color: Colors.white,
													shape: BoxShape.circle,
													boxShadow: [
														BoxShadow(
															color: Colors.black.withValues(alpha: 0.1),
															blurRadius: 4,
														),
													],
												),
												child: Container(
												  decoration: const BoxDecoration(
												    color: Color(0xFF1a1a2e),
												    shape: BoxShape.circle,
												  ),
												  child: IconButton(
												    icon: const Icon(Icons.edit, size: 20, color: Color(0xFF00f5ff)),
												    onPressed: () {
												      // Acción para cambiar foto de perfil
												    },
												  ),
												),
											),
										),
									],
								),
								const SizedBox(height: 24),
								_buildTextField(
									label: 'Nombre',
									initialValue: _nombre,
									icon: Icons.person,
									onSaved: (v) => _nombre = v ?? '',
								),
								const SizedBox(height: 16),
								_buildTextField(
									label: 'Usuario',
									initialValue: _username,
									icon: Icons.alternate_email,
									onSaved: (v) => _username = v ?? '',
								),
								const SizedBox(height: 16),
								_buildTextField(
									label: 'Posición',
									initialValue: _posicion,
									icon: Icons.sports_soccer,
									onSaved: (v) => _posicion = v ?? '',
								),
								const SizedBox(height: 16),
								Row(
									children: [
										Expanded(
											child: _buildTextField(
												label: 'Edad',
												initialValue: _edad,
												icon: Icons.cake,
												keyboardType: TextInputType.number,
												onSaved: (v) => _edad = v ?? '',
											),
										),
										const SizedBox(width: 16),
										Expanded(
											child: _buildTextField(
												label: 'Equipo',
												initialValue: _equipo,
												icon: Icons.sports,
												onSaved: (v) => _equipo = v ?? '',
											),
										),
									],
								),
								const SizedBox(height: 16),
								_buildTextField(
									label: 'Altura',
									initialValue: _altura,
									icon: Icons.height,
									onSaved: (v) => _altura = v ?? '',
								),
								const SizedBox(height: 16),
								_buildTextField(
									label: 'Peso',
									initialValue: _peso,
									icon: Icons.monitor_weight,
									onSaved: (v) => _peso = v ?? '',
								),
								const SizedBox(height: 32),
								SizedBox(
									width: double.infinity,
									height: 48,
									child: ElevatedButton(
										style: ElevatedButton.styleFrom(
											backgroundColor: const Color(0xFF1a1a2e),
											foregroundColor: const Color(0xFF00f5ff),
											shape: RoundedRectangleBorder(
												borderRadius: BorderRadius.circular(12),
											),
										),
										onPressed: () {
											if (_formKey.currentState?.validate() ?? false) {
												_formKey.currentState?.save();
												
												// Crear mapa con los datos actualizados
												final updatedData = {
													'nombre': _nombre,
													'username': _username,
													'posicion': _posicion,
													'edad': _edad,
													'equipo': _equipo,
													'altura': _altura,
													'peso': _peso,
												};
												
												ScaffoldMessenger.of(context).showSnackBar(
													const SnackBar(content: Text('Perfil actualizado')),
												);
												
												// Devolver los datos actualizados
												Navigator.of(context).pop(updatedData);
											}
										},
										child: const Text(
											'Guardar cambios',
											style: TextStyle(fontSize: 18, color: Color(0xFF00f5ff), fontWeight: FontWeight.bold),
										),
									),
								),
							],
						),
					),
				),
			),
		);
	}

	Widget _buildTextField({
		required String label,
		required String initialValue,
		required IconData icon,
		TextInputType keyboardType = TextInputType.text,
		required FormFieldSetter<String> onSaved,
	}) {
		return TextFormField(
			decoration: InputDecoration(
				labelText: label,
				prefixIcon: Icon(icon, color: const Color(0xFF1565C0)),
				border: OutlineInputBorder(
					borderRadius: BorderRadius.circular(12),
					borderSide: const BorderSide(color: Color(0xFF00f5ff), width: 2),
				),
				enabledBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(12),
					borderSide: const BorderSide(color: Color(0xFF00f5ff), width: 2),
				),
				focusedBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(12),
					borderSide: const BorderSide(color: Color(0xFF00f5ff), width: 2),
				),
				filled: true,
				fillColor: Colors.white,
			),
			initialValue: initialValue,
			keyboardType: keyboardType,
			style: const TextStyle(color: Color(0xFF1a1a2e), fontWeight: FontWeight.bold),
			validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
			onSaved: onSaved,
		);
	}
}
