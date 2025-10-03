
import 'package:flutter/material.dart';


class EditarPerfilPage extends StatefulWidget {
	@override
	State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
	final _formKey = GlobalKey<FormState>();
	// Simulación de datos actuales del usuario (en producción vendrían de un modelo o provider)
	String _nombre = 'Daniel Rodriguez';
	String _username = '@daniel_jr10';
	String _posicion = 'Delantero';
	String _edad = '20';
	String _equipo = 'FC Barcelona Academy';
	String _nacionalidad = 'Colombia';
	String _altura = '1.80m';
	String _peso = '75kg';

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.grey[50],
			appBar: AppBar(
				title: const Text('Editar Perfil'),
				backgroundColor: const Color(0xFF1565C0),
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
													color: const Color(0xFF1565C0),
													width: 3,
												),
												boxShadow: [
													BoxShadow(
														color: const Color(0xFF1565C0).withOpacity(0.2),
														blurRadius: 10,
														offset: const Offset(0, 3),
													),
												],
											),
											child: const CircleAvatar(
												radius: 50,
												backgroundColor: Color(0xFF1565C0),
												child: Icon(
													Icons.person,
													size: 60,
													color: Colors.white,
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
															color: Colors.black.withOpacity(0.1),
															blurRadius: 4,
														),
													],
												),
												child: IconButton(
													icon: const Icon(Icons.edit, size: 20, color: Color(0xFF1565C0)),
													onPressed: () {
														// Acción para cambiar foto de perfil
													},
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
								Row(
									children: [
										Expanded(
											child: _buildTextField(
												label: 'Nacionalidad',
												initialValue: _nacionalidad,
												icon: Icons.flag,
												onSaved: (v) => _nacionalidad = v ?? '',
											),
										),
										const SizedBox(width: 16),
										Expanded(
											child: _buildTextField(
												label: 'Altura',
												initialValue: _altura,
												icon: Icons.height,
												onSaved: (v) => _altura = v ?? '',
											),
										),
									],
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
											backgroundColor: const Color(0xFF1565C0),
											shape: RoundedRectangleBorder(
												borderRadius: BorderRadius.circular(12),
											),
										),
										onPressed: () {
											if (_formKey.currentState?.validate() ?? false) {
												_formKey.currentState?.save();
												// Aquí puedes agregar la lógica para guardar los cambios
												ScaffoldMessenger.of(context).showSnackBar(
													const SnackBar(content: Text('Perfil actualizado')),
												);
												Navigator.of(context).pop();
											}
										},
										child: const Text('Guardar cambios', style: TextStyle(fontSize: 18)),
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
				border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
				filled: true,
				fillColor: Colors.white,
			),
			initialValue: initialValue,
			keyboardType: keyboardType,
			validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
			onSaved: onSaved,
		);
	}
}
